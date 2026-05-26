/// Post-authentication destination based on profile display name (spec 017).
String resolvePostSignInRoute(String displayName) {
  return displayName.trim().isEmpty ? '/onboarding/name' : '/events';
}

bool profileHasDisplayName(String displayName) => displayName.trim().isNotEmpty;
