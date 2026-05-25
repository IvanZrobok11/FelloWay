//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:felloway_api/src/date_serializer.dart';
import 'package:felloway_api/src/model/date.dart';

import 'package:felloway_api/src/model/attendee.dart';
import 'package:felloway_api/src/model/auth_linkedin_mobile_complete_post_request.dart';
import 'package:felloway_api/src/model/auth_oauth_provider_token_post_request.dart';
import 'package:felloway_api/src/model/auth_refresh_post_request.dart';
import 'package:felloway_api/src/model/auth_session_get200_response.dart';
import 'package:felloway_api/src/model/chat_stream_token_get200_response.dart';
import 'package:felloway_api/src/model/cursor_page_meta.dart';
import 'package:felloway_api/src/model/error_response.dart';
import 'package:felloway_api/src/model/event.dart';
import 'package:felloway_api/src/model/event_list_page.dart';
import 'package:felloway_api/src/model/events_id_attendees_get200_response.dart';
import 'package:felloway_api/src/model/events_id_attendees_user_id_review_post_request.dart';
import 'package:felloway_api/src/model/events_id_trips_get200_response.dart';
import 'package:felloway_api/src/model/field_error.dart';
import 'package:felloway_api/src/model/interest_catalog_item.dart';
import 'package:felloway_api/src/model/interests_get200_response.dart';
import 'package:felloway_api/src/model/push_preferences.dart';
import 'package:felloway_api/src/model/review.dart';
import 'package:felloway_api/src/model/token_response.dart';
import 'package:felloway_api/src/model/trip.dart';
import 'package:felloway_api/src/model/trip_create.dart';
import 'package:felloway_api/src/model/trip_join_request.dart';
import 'package:felloway_api/src/model/trips_id_join_requests_get200_response.dart';
import 'package:felloway_api/src/model/user_profile.dart';
import 'package:felloway_api/src/model/user_profile_update.dart';
import 'package:felloway_api/src/model/users_id_reviews_get200_response.dart';
import 'package:felloway_api/src/model/users_me_avatar_post200_response.dart';

part 'serializers.g.dart';

@SerializersFor([
  Attendee,
  AuthLinkedinMobileCompletePostRequest,
  AuthOauthProviderTokenPostRequest,
  AuthRefreshPostRequest,
  AuthSessionGet200Response,
  ChatStreamTokenGet200Response,
  CursorPageMeta,
  ErrorResponse,
  Event,
  EventListPage,
  EventsIdAttendeesGet200Response,
  EventsIdAttendeesUserIdReviewPostRequest,
  EventsIdTripsGet200Response,
  FieldError,
  InterestCatalogItem,
  InterestsGet200Response,
  PushPreferences,
  Review,
  TokenResponse,
  Trip,
  TripCreate,
  TripJoinRequest,
  TripsIdJoinRequestsGet200Response,
  UserProfile,
  UserProfileUpdate,
  UsersIdReviewsGet200Response,
  UsersMeAvatarPost200Response,
])
Serializers serializers = (_$serializers.toBuilder()
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
