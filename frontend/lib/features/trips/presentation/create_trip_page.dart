import 'package:flutter/material.dart';
import 'package:felloway_client/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_scope.dart';
import '../../../app/theme/felloway_light_input.dart';
import '../../../shared/errors/connectivity_failure.dart';
import '../../../shared/errors/result.dart';
import '../data/trips_repository.dart';
import '../domain/trip_chat.dart';

class CreateTripPage extends StatefulWidget {
  const CreateTripPage({
    super.key,
    required this.eventId,
    this.suggestedCity = '',
  });

  final String eventId;
  final String suggestedCity;

  @override
  State<CreateTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _routeCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  DateTime _departure = DateTime.now().add(const Duration(hours: 2));
  TripTransportRole _role = TripTransportRole.either;
  double _capacity = 4;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.suggestedCity.isNotEmpty) {
      _cityCtrl.text = widget.suggestedCity;
    }
  }

  @override
  void dispose() {
    _routeCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  bool get _formValid {
    return _routeCtrl.text.trim().isNotEmpty &&
        _cityCtrl.text.trim().isNotEmpty &&
        _capacity >= 1 &&
        _capacity <= 20;
  }

  Future<void> _pickDeparture() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _departure,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_departure),
    );
    if (t == null || !mounted) return;
    setState(() {
      _departure = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    });
  }

  Future<void> _submit() async {
    if (!_formValid) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    final repo = AppScope.tripsOf(context);
    final draft = CreateTripDraft(
      routeLabel: _routeCtrl.text.trim(),
      departureAt: _departure,
      transportRole: _role,
      targetCityLabel: _cityCtrl.text.trim(),
      capacity: _capacity.round(),
    );
    final r = await repo.createTrip(widget.eventId, draft);
    if (!mounted) return;
    setState(() => _saving = false);
    switch (r) {
      case Success(:final value):
        final _ = value;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.tripCreateSuccess)));
        context.pop(true);
      case Failure(:final error):
        showActionFailureSnackBar(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lightInput = context.fellowayLightInput;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tripCreateTitle)),
      body: Semantics(
        container: true,
        label:
            '${l10n.tripCreateTitle}. ${l10n.tripRouteLabel}. ${l10n.tripTargetCityLabel}',
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              key: const Key('trip_route_field'),
              controller: _routeCtrl,
              style: lightInput.textStyle,
              decoration: FellowayLightInput.decoration(
                context,
                labelText: l10n.tripRouteLabel,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('trip_city_field'),
              controller: _cityCtrl,
              style: lightInput.textStyle,
              decoration: FellowayLightInput.decoration(
                context,
                labelText: l10n.tripTargetCityLabel,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(l10n.tripDepartureLabel),
              subtitle: Text(l10n.tripDepartureValue(_formatDt(_departure))),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDeparture,
            ),
            const SizedBox(height: 8),
            Text(l10n.tripRoleLabel),
            SegmentedButton<TripTransportRole>(
              segments: [
                ButtonSegment(
                  value: TripTransportRole.driver,
                  label: Text(l10n.tripRoleDriver),
                ),
                ButtonSegment(
                  value: TripTransportRole.passenger,
                  label: Text(l10n.tripRolePassenger),
                ),
                ButtonSegment(
                  value: TripTransportRole.either,
                  label: Text(l10n.tripRoleEither),
                ),
              ],
              selected: {_role},
              onSelectionChanged: (s) => setState(() => _role = s.first),
            ),
            const SizedBox(height: 16),
            Text(l10n.tripCapacityLabel(_capacity.round())),
            Slider(
              key: const Key('trip_capacity_slider'),
              value: _capacity,
              min: 1,
              max: 20,
              divisions: 19,
              label: '${_capacity.round()}',
              onChanged: (v) => setState(() => _capacity = v),
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('trip_create_submit'),
              onPressed: (_formValid && !_saving) ? _submit : null,
              child: _saving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.tripCreateSubmit),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDt(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
