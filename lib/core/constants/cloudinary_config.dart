/// Cloudinary configuration for image uploads
class CloudinaryConfig {
  static const String cloudName = 'dx5kqmj5y';
  static const String uploadPreset = 'trade_logger_unsigned';

  // Upload API endpoint
  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
}
