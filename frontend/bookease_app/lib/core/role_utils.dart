import '../models/user.dart';

const String customerRole = 'Customer';
const String businessOwnerRole = 'BusinessOwner';
const String adminRole = 'Admin';

String homeRouteForRole(String? role) {
  switch (role) {
    case businessOwnerRole:
      return '/my-businesses';
    case adminRole:
      return '/admin';
    case customerRole:
    default:
      return '/businesses';
  }
}

String roleLabelTr(String? role) {
  switch (role) {
    case businessOwnerRole:
      return 'Isletme Sahibi';
    case adminRole:
      return 'Admin';
    case customerRole:
    default:
      return 'Musteri';
  }
}

bool canAccessRouteForRole(String? role, String path) {
  if (path == '/login' || path == '/register') {
    return true;
  }

  switch (role) {
    case businessOwnerRole:
      return path == '/profile' ||
          path == '/my-businesses' ||
          path.startsWith('/my-businesses/') ||
          path == '/owner-bookings';
    case adminRole:
      return path == '/profile' ||
          path == '/admin' ||
          path == '/admin/businesses' ||
          path.startsWith('/admin/businesses/') ||
          path == '/businesses' ||
          path.startsWith('/businesses/') ||
          path.startsWith('/services/');
    case customerRole:
    default:
      return path == '/profile' ||
          path == '/businesses' ||
          path.startsWith('/businesses/') ||
          path.startsWith('/services/') ||
          path == '/bookings' ||
          path.startsWith('/bookings/');
  }
}

bool isCustomer(AuthUser? user) => user?.role == customerRole;
bool isBusinessOwner(AuthUser? user) => user?.role == businessOwnerRole;
bool isAdmin(AuthUser? user) => user?.role == adminRole;
