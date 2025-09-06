class EndPoints {
    static final baseUrl = "https://api.rutsnrides.com/api/";
  //static final baseUrl = "http://192.168.31.86:8080/api/";

  //auth
  static final auth = "auth";
  static final register = "$auth/register";
  static final login = "$auth/login";

  //booking
  static final booking = "form_booking";
  static final getAllBooking = "$booking/";
  static final createBooking = "$booking/";

  //attendance
  static final attendance = "form_attendance";
  static final getAllAttendance = "$attendance/";
  static final createAttendence = "$attendance/";

  //form
  static final form = "form";
  static final getAllformEnquiry = "$form/";
}
