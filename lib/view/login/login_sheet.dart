import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:bubbly/api/api_service.dart';
import 'package:bubbly/custom_view/common_ui.dart';
import 'package:bubbly/custom_view/privacy_policy_view.dart';
import 'package:bubbly/languages/languages_keys.dart';
import 'package:bubbly/utils/assert_image.dart';
import 'package:bubbly/utils/colors.dart';
import 'package:bubbly/utils/const_res.dart';
import 'package:bubbly/utils/font_res.dart';
import 'package:bubbly/utils/key_res.dart';
import 'package:bubbly/utils/my_loading/my_loading.dart';
import 'package:bubbly/utils/session_manager.dart';
import 'package:bubbly/utils/url_res.dart';
import 'package:bubbly/view/email/sign_in_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginSheet extends StatelessWidget {
  final SessionManager sessionManager = SessionManager();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    initData();
    return Consumer(builder: (context, MyLoading myLoading, child) {
      return Container(
        height: (MediaQuery.of(context).size.height -
            AppBar().preferredSize.height * 1.5),
        decoration: BoxDecoration(
            color:
                myLoading.isDark ? ColorRes.colorPrimaryDark : ColorRes.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: Icon(Icons.close_rounded),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Image.asset(
                            myLoading.isDark ? icLogo : icLogoLight,
                            height: 90)),
                    Text('${LKey.signUpFor.tr} $appName',
                        style: TextStyle(
                            fontSize: 22, fontFamily: FontRes.fNSfUiSemiBold)),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text(
                          LKey.createAProfileFollowOtherCreatorsNBuildYourFanFollowingBy
                              .tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, fontFamily: FontRes.fNSfUiLight)),
                    ),
                    SizedBox(height: 15),
                    Visibility(
                      visible: Platform.isIOS,
                      child: SocialButton(
                          onTap: () {
                            _signInWithApple().then(
                              (value) {
                                if (value != null) {
                                  print('-------------------- :: ${value}');
                                  _callApiForLogin(
                                      value, KeyRes.apple, context, myLoading);
                                } else {
                                  CommonUI.showToast(
                                      msg: LKey.somethingWentWrong.tr);
                                }
                              },
                            );
                          },
                          image: icApple,
                          isDarkMode: myLoading.isDark,
                          name: LKey.singInWithApple.tr),
                    ),
                    SocialButton(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInScreen(),
                              )).then((value) {});
                        },
                        isDarkMode: myLoading.isDark,
                        image: icEmail,
                        name: LKey.singInWithEmail.tr),
                    SocialButton(
                        onTap: () {
                          CommonUI.showLoader(context);
                          _signInWithGoogle().then((value) {
                            Navigator.pop(context);

                            if (value != null) {
                              print('null');
                              _callApiForLogin(
                                  value, KeyRes.google, context, myLoading);
                            } else {
                              print('null');
                            }
                          });
                        },
                        isGoogleIcon: true,
                        isDarkMode: myLoading.isDark,
                        image: icGoogle,
                        name: LKey.singInWithGoogle.tr),
                    SizedBox(height: 15),
                    PrivacyPolicyView(),
                    SizedBox(height: AppBar().preferredSize.height / 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  /*Future<User?> _signInWithGoogle() async {
  try {
    // Trigger the Google Sign-In flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      clientId:
          '463711886346-3561g7e03arnm5cb1vchc07pjaip8drl.apps.googleusercontent.com',
      scopes: ['email', 'profile'],
    ).signIn();

    // If the user cancels the sign-in flow
    if (googleUser == null) {
      print('LOG ============ Sign-in was cancelled by the user.');
      return null;
    }

    // Obtain the Google Sign-In authentication details
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Check if tokens are null
    if (googleAuth.accessToken == null || googleAuth.idToken == null) {
      print('LOG ============ Missing Google Auth tokens.');
      return null;
    }

    // Create a credential for Firebase authentication
    final AuthCredential googleCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credentials
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(googleCredential);

    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    print('LOG ============ FirebaseAuthException: ${e.message}');
    return null;
  } catch (e) {
    print('LOG ============ Unexpected error: $e');
    return null;
  }
}*/ // invalid token
Future<User?> _signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    if (googleAuth?.accessToken == null || googleAuth?.idToken == null) {
      return null;
    }
    final googleCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    UserCredential? authResult;
    try {
      authResult = await _auth.signInWithCredential(googleCredential);
    } on FirebaseAuthException catch (e) {
      print('LOG ============ ${e.message}');
    }
    return authResult?.user;
  }

  Future<User?> _signInWithApple() async {
    CommonUI.showLoader(Get.context!);
    try {
      // Request Apple ID credentials
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName
        ],
      );

      // Create an OAuth credential using the Apple ID token
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
      );

      // Extract the display name
      String? displayName =
          '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
              .trim();
      print('====== $displayName');

      // Extract the email
      String? userEmail = appleCredential.email ?? '';
      print('====== $userEmail');

      // Sign in to Firebase with the OAuth credential
      final authResult = await _auth.signInWithCredential(oauthCredential);
      final firebaseUser = authResult.user;

      // Update display name if it's available and not already set
      if (displayName.isNotEmpty && firebaseUser?.displayName == null) {
        print('Updating display name... ${displayName}');
        await firebaseUser?.updateDisplayName(displayName);
        await firebaseUser?.updateProfile(displayName: displayName);
      }

      // Update email if it's available and not already set
      if (userEmail.isNotEmpty && firebaseUser?.email == null) {
        print('Updating email... ${userEmail}');
        await firebaseUser?.verifyBeforeUpdateEmail(userEmail);
      }
      Get.back();
      return firebaseUser;
    } catch (e) {
      Get.back();
      // Log any exceptions that occur during the process
      log(e.toString());
    }

    // Return null if sign-in fails
    return null;
  }

  void _callApiForLogin(
      User value, String loginType, BuildContext context, MyLoading myLoading) {
    HashMap<String, String?> params = new HashMap();
    print(sessionManager.getString(KeyRes.deviceToken));
    print(value.email != null ? value.email!.split('@')[0] : value.uid);

    params[UrlRes.deviceToken] = sessionManager.getString(KeyRes.deviceToken);
    params[UrlRes.userEmail] = value.email;
    params[UrlRes.fullName] = value.displayName ??
        (value.email != null ? value.email!.split('@')[0] : value.uid);
    params[UrlRes.loginType] = loginType;
    params[UrlRes.userName] =
        value.email != null ? value.email!.split('@')[0] : value.uid;
    params[UrlRes.identity] = value.email ?? value.uid;
    params[UrlRes.platform] = Platform.isAndroid ? "1" : "2";
    CommonUI.showLoader(context);
    ApiService().registerUser(params).then(
      (value) {
        Navigator.pop(context);
        if (value.status == 200) {
          sessionManager.saveBoolean(KeyRes.login, true);
          myLoading.setSelectedItem(0);
          myLoading.setUser(value);
          Navigator.pop(context);
        }
      },
    );
  }

  Future<void> initData() async {
    await sessionManager.initPref();
  }
}

class SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final String image;
  final String name;
  final bool isDarkMode;
  final bool isGoogleIcon;

  const SocialButton(
      {Key? key,
      required this.onTap,
      required this.image,
      required this.name,
      required this.isDarkMode,
      this.isGoogleIcon = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 45,
        width: 210,
        margin: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
            color: isDarkMode ? ColorRes.colorPrimary : ColorRes.greyShade100,
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Image.asset(image,
                  height: 23,
                  color: isGoogleIcon
                      ? null
                      : isDarkMode
                          ? ColorRes.white
                          : Colors.black),
            ),
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontFamily: FontRes.fNSfUiMedium,
              ),
            )
          ],
        ),
      ),
    );
  }
}
