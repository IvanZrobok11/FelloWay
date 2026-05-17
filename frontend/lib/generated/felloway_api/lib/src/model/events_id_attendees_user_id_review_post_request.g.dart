// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_id_attendees_user_id_review_post_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$EventsIdAttendeesUserIdReviewPostRequest
    extends EventsIdAttendeesUserIdReviewPostRequest {
  @override
  final int rating;
  @override
  final String? comment;

  factory _$EventsIdAttendeesUserIdReviewPostRequest(
          [void Function(EventsIdAttendeesUserIdReviewPostRequestBuilder)?
              updates]) =>
      (EventsIdAttendeesUserIdReviewPostRequestBuilder()..update(updates))
          ._build();

  _$EventsIdAttendeesUserIdReviewPostRequest._(
      {required this.rating, this.comment})
      : super._();
  @override
  EventsIdAttendeesUserIdReviewPostRequest rebuild(
          void Function(EventsIdAttendeesUserIdReviewPostRequestBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  EventsIdAttendeesUserIdReviewPostRequestBuilder toBuilder() =>
      EventsIdAttendeesUserIdReviewPostRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is EventsIdAttendeesUserIdReviewPostRequest &&
        rating == other.rating &&
        comment == other.comment;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, rating.hashCode);
    _$hash = $jc(_$hash, comment.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'EventsIdAttendeesUserIdReviewPostRequest')
          ..add('rating', rating)
          ..add('comment', comment))
        .toString();
  }
}

class EventsIdAttendeesUserIdReviewPostRequestBuilder
    implements
        Builder<EventsIdAttendeesUserIdReviewPostRequest,
            EventsIdAttendeesUserIdReviewPostRequestBuilder> {
  _$EventsIdAttendeesUserIdReviewPostRequest? _$v;

  int? _rating;
  int? get rating => _$this._rating;
  set rating(int? rating) => _$this._rating = rating;

  String? _comment;
  String? get comment => _$this._comment;
  set comment(String? comment) => _$this._comment = comment;

  EventsIdAttendeesUserIdReviewPostRequestBuilder() {
    EventsIdAttendeesUserIdReviewPostRequest._defaults(this);
  }

  EventsIdAttendeesUserIdReviewPostRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _rating = $v.rating;
      _comment = $v.comment;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(EventsIdAttendeesUserIdReviewPostRequest other) {
    _$v = other as _$EventsIdAttendeesUserIdReviewPostRequest;
  }

  @override
  void update(
      void Function(EventsIdAttendeesUserIdReviewPostRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  EventsIdAttendeesUserIdReviewPostRequest build() => _build();

  _$EventsIdAttendeesUserIdReviewPostRequest _build() {
    final _$result = _$v ??
        _$EventsIdAttendeesUserIdReviewPostRequest._(
          rating: BuiltValueNullFieldError.checkNotNull(
              rating, r'EventsIdAttendeesUserIdReviewPostRequest', 'rating'),
          comment: comment,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
