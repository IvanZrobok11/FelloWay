# felloway_api.api.DefaultApi

## Load the API package
```dart
import 'package:felloway_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authLogoutPost**](DefaultApi.md#authlogoutpost) | **POST** /auth/logout | Revoke refresh token
[**authOauthProviderTokenPost**](DefaultApi.md#authoauthprovidertokenpost) | **POST** /auth/oauth/{provider}/token | Exchange OAuth authorization code for API tokens
[**authRefreshPost**](DefaultApi.md#authrefreshpost) | **POST** /auth/refresh | Refresh access token
[**chatStreamTokenGet**](DefaultApi.md#chatstreamtokenget) | **GET** /chat/stream-token | GetStream user token for mobile SDK
[**eventsGet**](DefaultApi.md#eventsget) | **GET** /events | List events (paginated, filterable)
[**eventsIdAttendDelete**](DefaultApi.md#eventsidattenddelete) | **DELETE** /events/{id}/attend | Leave event
[**eventsIdAttendPost**](DefaultApi.md#eventsidattendpost) | **POST** /events/{id}/attend | Join event
[**eventsIdAttendeesGet**](DefaultApi.md#eventsidattendeesget) | **GET** /events/{id}/attendees | List attendees (subscribers only)
[**eventsIdAttendeesUserIdReviewPost**](DefaultApi.md#eventsidattendeesuseridreviewpost) | **POST** /events/{id}/attendees/{userId}/review | Post-event review
[**eventsIdGet**](DefaultApi.md#eventsidget) | **GET** /events/{id} | Event detail
[**eventsIdTripsGet**](DefaultApi.md#eventsidtripsget) | **GET** /events/{id}/trips | List trip chats for event
[**eventsIdTripsPost**](DefaultApi.md#eventsidtripspost) | **POST** /events/{id}/trips | Create trip chat
[**tripsIdApproveUserIdPost**](DefaultApi.md#tripsidapproveuseridpost) | **POST** /trips/{id}/approve/{userId} | Approve join request
[**tripsIdJoinDelete**](DefaultApi.md#tripsidjoindelete) | **DELETE** /trips/{id}/join | Cancel pending join request
[**tripsIdJoinPost**](DefaultApi.md#tripsidjoinpost) | **POST** /trips/{id}/join | Request to join trip
[**tripsIdJoinRequestsGet**](DefaultApi.md#tripsidjoinrequestsget) | **GET** /trips/{id}/join-requests | Pending join requests (trip owner)
[**usersIdBlockPost**](DefaultApi.md#usersidblockpost) | **POST** /users/{id}/block | Block a user
[**usersIdReviewsGet**](DefaultApi.md#usersidreviewsget) | **GET** /users/{id}/reviews | List reviews for a user
[**usersMeAvatarPost**](DefaultApi.md#usersmeavatarpost) | **POST** /users/me/avatar | Upload avatar (multipart)
[**usersMeGet**](DefaultApi.md#usersmeget) | **GET** /users/me | Current user profile
[**usersMePushPreferencesPut**](DefaultApi.md#usersmepushpreferencesput) | **PUT** /users/me/push-preferences | Update notification toggles
[**usersMePut**](DefaultApi.md#usersmeput) | **PUT** /users/me | Update current user profile


# **authLogoutPost**
> authLogoutPost()

Revoke refresh token

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();

try {
    api.authLogoutPost();
} catch on DioException (e) {
    print('Exception when calling DefaultApi->authLogoutPost: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authOauthProviderTokenPost**
> TokenResponse authOauthProviderTokenPost(provider, authOauthProviderTokenPostRequest)

Exchange OAuth authorization code for API tokens

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final String provider = provider_example; // String | 
final AuthOauthProviderTokenPostRequest authOauthProviderTokenPostRequest = ; // AuthOauthProviderTokenPostRequest | 

try {
    final response = api.authOauthProviderTokenPost(provider, authOauthProviderTokenPostRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->authOauthProviderTokenPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **provider** | **String**|  | 
 **authOauthProviderTokenPostRequest** | [**AuthOauthProviderTokenPostRequest**](AuthOauthProviderTokenPostRequest.md)|  | 

### Return type

[**TokenResponse**](TokenResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authRefreshPost**
> TokenResponse authRefreshPost(authRefreshPostRequest)

Refresh access token

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final AuthRefreshPostRequest authRefreshPostRequest = ; // AuthRefreshPostRequest | 

try {
    final response = api.authRefreshPost(authRefreshPostRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->authRefreshPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **authRefreshPostRequest** | [**AuthRefreshPostRequest**](AuthRefreshPostRequest.md)|  | 

### Return type

[**TokenResponse**](TokenResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **chatStreamTokenGet**
> ChatStreamTokenGet200Response chatStreamTokenGet()

GetStream user token for mobile SDK

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();

try {
    final response = api.chatStreamTokenGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->chatStreamTokenGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ChatStreamTokenGet200Response**](ChatStreamTokenGet200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **eventsGet**
> EventListPage eventsGet(cursor, q, city, interest, limit)

List events (paginated, filterable)

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final String cursor = cursor_example; // String | 
final String q = q_example; // String | 
final String city = city_example; // String | 
final String interest = interest_example; // String | 
final int limit = 56; // int | 

try {
    final response = api.eventsGet(cursor, q, city, interest, limit);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->eventsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **cursor** | **String**|  | [optional] 
 **q** | **String**|  | [optional] 
 **city** | **String**|  | [optional] 
 **interest** | **String**|  | [optional] 
 **limit** | **int**|  | [optional] 

### Return type

[**EventListPage**](EventListPage.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **eventsIdAttendDelete**
> eventsIdAttendDelete(id)

Leave event

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.eventsIdAttendDelete(id);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->eventsIdAttendDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **eventsIdAttendPost**
> eventsIdAttendPost(id)

Join event

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.eventsIdAttendPost(id);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->eventsIdAttendPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **eventsIdAttendeesGet**
> EventsIdAttendeesGet200Response eventsIdAttendeesGet(id)

List attendees (subscribers only)

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.eventsIdAttendeesGet(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->eventsIdAttendeesGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**EventsIdAttendeesGet200Response**](EventsIdAttendeesGet200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **eventsIdAttendeesUserIdReviewPost**
> eventsIdAttendeesUserIdReviewPost(id, userId, eventsIdAttendeesUserIdReviewPostRequest)

Post-event review

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String userId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final EventsIdAttendeesUserIdReviewPostRequest eventsIdAttendeesUserIdReviewPostRequest = ; // EventsIdAttendeesUserIdReviewPostRequest | 

try {
    api.eventsIdAttendeesUserIdReviewPost(id, userId, eventsIdAttendeesUserIdReviewPostRequest);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->eventsIdAttendeesUserIdReviewPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **userId** | **String**|  | 
 **eventsIdAttendeesUserIdReviewPostRequest** | [**EventsIdAttendeesUserIdReviewPostRequest**](EventsIdAttendeesUserIdReviewPostRequest.md)|  | [optional] 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **eventsIdGet**
> Event eventsIdGet(id)

Event detail

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.eventsIdGet(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->eventsIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**Event**](Event.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **eventsIdTripsGet**
> EventsIdTripsGet200Response eventsIdTripsGet(id)

List trip chats for event

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.eventsIdTripsGet(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->eventsIdTripsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**EventsIdTripsGet200Response**](EventsIdTripsGet200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **eventsIdTripsPost**
> Trip eventsIdTripsPost(id, tripCreate)

Create trip chat

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final TripCreate tripCreate = ; // TripCreate | 

try {
    final response = api.eventsIdTripsPost(id, tripCreate);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->eventsIdTripsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **tripCreate** | [**TripCreate**](TripCreate.md)|  | [optional] 

### Return type

[**Trip**](Trip.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tripsIdApproveUserIdPost**
> tripsIdApproveUserIdPost(id, userId)

Approve join request

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 
final String userId = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.tripsIdApproveUserIdPost(id, userId);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->tripsIdApproveUserIdPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 
 **userId** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tripsIdJoinDelete**
> tripsIdJoinDelete(id)

Cancel pending join request

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.tripsIdJoinDelete(id);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->tripsIdJoinDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tripsIdJoinPost**
> tripsIdJoinPost(id)

Request to join trip

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.tripsIdJoinPost(id);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->tripsIdJoinPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **tripsIdJoinRequestsGet**
> TripsIdJoinRequestsGet200Response tripsIdJoinRequestsGet(id)

Pending join requests (trip owner)

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.tripsIdJoinRequestsGet(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->tripsIdJoinRequestsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**TripsIdJoinRequestsGet200Response**](TripsIdJoinRequestsGet200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **usersIdBlockPost**
> usersIdBlockPost(id)

Block a user

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    api.usersIdBlockPost(id);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->usersIdBlockPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **usersIdReviewsGet**
> UsersIdReviewsGet200Response usersIdReviewsGet(id)

List reviews for a user

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final String id = 38400000-8cf0-11bd-b23e-10b96e4ef00d; // String | 

try {
    final response = api.usersIdReviewsGet(id);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->usersIdReviewsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **String**|  | 

### Return type

[**UsersIdReviewsGet200Response**](UsersIdReviewsGet200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **usersMeAvatarPost**
> UsersMeAvatarPost200Response usersMeAvatarPost(file)

Upload avatar (multipart)

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final MultipartFile file = BINARY_DATA_HERE; // MultipartFile | 

try {
    final response = api.usersMeAvatarPost(file);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->usersMeAvatarPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **file** | **MultipartFile**|  | [optional] 

### Return type

[**UsersMeAvatarPost200Response**](UsersMeAvatarPost200Response.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: multipart/form-data
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **usersMeGet**
> UserProfile usersMeGet()

Current user profile

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();

try {
    final response = api.usersMeGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->usersMeGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**UserProfile**](UserProfile.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **usersMePushPreferencesPut**
> usersMePushPreferencesPut(pushPreferences)

Update notification toggles

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final PushPreferences pushPreferences = ; // PushPreferences | 

try {
    api.usersMePushPreferencesPut(pushPreferences);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->usersMePushPreferencesPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pushPreferences** | [**PushPreferences**](PushPreferences.md)|  | [optional] 

### Return type

void (empty response body)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **usersMePut**
> UserProfile usersMePut(userProfileUpdate)

Update current user profile

### Example
```dart
import 'package:felloway_api/api.dart';

final api = FellowayApi().getDefaultApi();
final UserProfileUpdate userProfileUpdate = ; // UserProfileUpdate | 

try {
    final response = api.usersMePut(userProfileUpdate);
    print(response);
} catch on DioException (e) {
    print('Exception when calling DefaultApi->usersMePut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userProfileUpdate** | [**UserProfileUpdate**](UserProfileUpdate.md)|  | 

### Return type

[**UserProfile**](UserProfile.md)

### Authorization

[BearerAuth](../README.md#BearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

