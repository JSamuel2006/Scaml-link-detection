const String kBaseUrl = 'http://10.0.2.2:8000'; // Android emulator → localhost
// const String kBaseUrl = 'http://YOUR_IP:8000'; // Real device

// Platforms
const List<String> kPlatforms = [
  'manual',
  'whatsapp',
  'instagram',
  'telegram',
  'sms',
];

// Storage keys
const String kTokenKey = 'auth_token';
const String kRoleKey = 'user_role';
const String kNameKey = 'user_name';
const String kUserIdKey = 'user_id';
const String kPermissionsGrantedKey = 'permissions_granted';

// Result colors / labels
const Map<String, String> kResultLabels = {
  'safe': 'SAFE',
  'suspicious': 'SUSPICIOUS',
  'scam': 'SCAM',
};
