class ConstRes {
  static final String base = 'https://shortz.everests.co.uk/';
  static const String apiKey = 'dev123';
  static final String baseUrl = '${base}api/';

  static final String itemBaseUrl = 'https://d139xnf84yjx1z.cloudfront.net/bubbly/';

  // Agora Credential
  static final String customerId = 'c575b5922d4c4c7ab01561af71d39e96';
  static final String customerSecret = '39cfbd5e04134b2b98e7dd1404988aa1';

  // Starting screen open end_user_license_agreement sheet link
  static final String agreementUrl = "https://work.bubbletokapp.com/";

  static final String bubblyCamera = 'bubbly_camera';
  static final bool isDialog = false;
}

const String appName = 'Shortz';
const companyName = 'JIREH';
const defaultPlaceHolderText = 'S';
const byDefaultLanguage = 'en';

const int paginationLimit = 10;

// Live broadcast Video Quality : Resolution (Width×Height)
int liveWeight = 640;
int liveHeight = 480;
int liveFrameRate = 60; //Frame rate (fps）

// Image Quality
double maxHeight = 720;
double maxWidth = 720;
int imageQuality = 100;

// max Video upload limit in MB
int maxUploadMB = 512;
// max Video upload second
int maxUploadSecond = 60;

//Strings
const List<String> paymentMethods = ['Paypal', 'Paytm', 'Other'];
const List<String> reportReasons = ['Sexual', 'Nudity', 'Religion', 'Other'];

// Video Moderation models  :- https://sightengine.com/docs/moderate-stored-video-asynchronously
String nudityModels = 'nudity,wad';
