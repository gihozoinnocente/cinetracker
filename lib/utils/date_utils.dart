class MovieDateUtils {
  static String formatReleaseDate(String date) {
    if (date.isEmpty) return 'Release date unknown';
    
    try {
      final DateTime releaseDate = DateTime.parse(date);
      final List<String> months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      
      return '${months[releaseDate.month - 1]} ${releaseDate.day}, ${releaseDate.year}';
    } catch (e) {
      return date;
    }
  }
}