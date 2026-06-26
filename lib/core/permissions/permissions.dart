enum Permission {
  viewHome,
  viewMedia,
  viewSettings,
  viewLogin,
  viewEmailVerification,
  viewCompleteProfile,
  viewProfile,
  viewChannels,
  viewBanners,
  createBanner,
  editBanner,
  deleteBanner,
  createChannel,
  editChannel,
  deleteChannel,
  manageUsers,
  sendNotifications,
}

class PermissionChecker {
  static const _rolePermissions = <String, List<Permission>>{
    'guest': [
      Permission.viewHome,
      Permission.viewMedia,
      Permission.viewSettings,
      Permission.viewLogin,
    ],
    'user': [
      Permission.viewHome,
      Permission.viewMedia,
      Permission.viewSettings,
      Permission.viewProfile,
      Permission.viewChannels,
    ],
    'admin': [
      Permission.viewHome,
      Permission.viewMedia,
      Permission.viewSettings,
      Permission.viewProfile,
      Permission.viewChannels,
      Permission.viewBanners,
      Permission.createBanner,
      Permission.editBanner,
      Permission.deleteBanner,
      Permission.createChannel,
      Permission.editChannel,
      Permission.deleteChannel,
      Permission.manageUsers,
      Permission.sendNotifications,
    ],
    'moderator': [
      Permission.viewHome,
      Permission.viewMedia,
      Permission.viewSettings,
      Permission.viewProfile,
      Permission.viewChannels,
      Permission.viewBanners,
    ],
    'editor': [
      Permission.viewHome,
      Permission.viewMedia,
      Permission.viewSettings,
      Permission.viewProfile,
      Permission.viewChannels,
      Permission.viewBanners,
      Permission.createBanner,
      Permission.editBanner,
    ],
  };

  static bool has(String role, Permission permission) {
    return _rolePermissions[role]?.contains(permission) ?? false;
  }

  static List<Permission> permissionsFor(String role) {
    return _rolePermissions[role] ?? _rolePermissions['guest']!;
  }
}
