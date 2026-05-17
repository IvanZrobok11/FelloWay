import 'package:test/test.dart';
import 'package:felloway_api/felloway_api.dart';

/// tests for DefaultApi
void main() {
  final instance = FellowayApi().getDefaultApi();

  group(DefaultApi, () {
    // Revoke refresh token
    //
    //Future authLogoutPost() async
    test('test authLogoutPost', () async {
      // TODO
    });

    // Exchange OAuth authorization code for API tokens
    //
    //Future<TokenResponse> authOauthProviderTokenPost(String provider, AuthOauthProviderTokenPostRequest authOauthProviderTokenPostRequest) async
    test('test authOauthProviderTokenPost', () async {
      // TODO
    });

    // Refresh access token
    //
    //Future<TokenResponse> authRefreshPost(AuthRefreshPostRequest authRefreshPostRequest) async
    test('test authRefreshPost', () async {
      // TODO
    });

    // GetStream user token for mobile SDK
    //
    //Future<ChatStreamTokenGet200Response> chatStreamTokenGet() async
    test('test chatStreamTokenGet', () async {
      // TODO
    });

    // List events (paginated, filterable)
    //
    //Future<EventListPage> eventsGet({ String cursor, String q, String city, String interest, int limit }) async
    test('test eventsGet', () async {
      // TODO
    });

    // Leave event
    //
    //Future eventsIdAttendDelete(String id) async
    test('test eventsIdAttendDelete', () async {
      // TODO
    });

    // Join event
    //
    //Future eventsIdAttendPost(String id) async
    test('test eventsIdAttendPost', () async {
      // TODO
    });

    // List attendees (subscribers only)
    //
    //Future<EventsIdAttendeesGet200Response> eventsIdAttendeesGet(String id) async
    test('test eventsIdAttendeesGet', () async {
      // TODO
    });

    // Post-event review
    //
    //Future eventsIdAttendeesUserIdReviewPost(String id, String userId, { EventsIdAttendeesUserIdReviewPostRequest eventsIdAttendeesUserIdReviewPostRequest }) async
    test('test eventsIdAttendeesUserIdReviewPost', () async {
      // TODO
    });

    // Event detail
    //
    //Future<Event> eventsIdGet(String id) async
    test('test eventsIdGet', () async {
      // TODO
    });

    // List trip chats for event
    //
    //Future<EventsIdTripsGet200Response> eventsIdTripsGet(String id) async
    test('test eventsIdTripsGet', () async {
      // TODO
    });

    // Create trip chat
    //
    //Future<Trip> eventsIdTripsPost(String id, { TripCreate tripCreate }) async
    test('test eventsIdTripsPost', () async {
      // TODO
    });

    // Approve join request
    //
    //Future tripsIdApproveUserIdPost(String id, String userId) async
    test('test tripsIdApproveUserIdPost', () async {
      // TODO
    });

    // Cancel pending join request
    //
    //Future tripsIdJoinDelete(String id) async
    test('test tripsIdJoinDelete', () async {
      // TODO
    });

    // Request to join trip
    //
    //Future tripsIdJoinPost(String id) async
    test('test tripsIdJoinPost', () async {
      // TODO
    });

    // Pending join requests (trip owner)
    //
    //Future<TripsIdJoinRequestsGet200Response> tripsIdJoinRequestsGet(String id) async
    test('test tripsIdJoinRequestsGet', () async {
      // TODO
    });

    // Block a user
    //
    //Future usersIdBlockPost(String id) async
    test('test usersIdBlockPost', () async {
      // TODO
    });

    // List reviews for a user
    //
    //Future<UsersIdReviewsGet200Response> usersIdReviewsGet(String id) async
    test('test usersIdReviewsGet', () async {
      // TODO
    });

    // Upload avatar (multipart)
    //
    //Future<UsersMeAvatarPost200Response> usersMeAvatarPost({ MultipartFile file }) async
    test('test usersMeAvatarPost', () async {
      // TODO
    });

    // Current user profile
    //
    //Future<UserProfile> usersMeGet() async
    test('test usersMeGet', () async {
      // TODO
    });

    // Update notification toggles
    //
    //Future usersMePushPreferencesPut({ PushPreferences pushPreferences }) async
    test('test usersMePushPreferencesPut', () async {
      // TODO
    });

    // Update current user profile
    //
    //Future<UserProfile> usersMePut(UserProfileUpdate userProfileUpdate) async
    test('test usersMePut', () async {
      // TODO
    });
  });
}
