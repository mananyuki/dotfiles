{ ... }:
{
  system.defaults = {
    NSGlobalDomain = {
      ApplePressAndHoldEnabled = true;
      AppleShowAllExtensions = true;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };

    dock = {
      autohide = true;
      persistent-apps = [ ];
      tilesize = 36;
      expose-group-apps = true;
    };

    finder = {
      AppleShowAllFiles = true;
      FXDefaultSearchScope = "SCcf";
      FXPreferredViewStyle = "clmv";
      ShowPathbar = true;
      ShowStatusBar = true;
    };

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };

    CustomUserPreferences = {
      NSGlobalDomain = {
        AppleLanguages = [
          "ja-JP"
          "en-JP"
        ];
        AppleLocale = "ja_JP";
        NSAutomaticTextCompletionEnabled = false;
        NSLinguisticDataAssetsRequested = [
          "ja"
          "ja_JP"
          "en"
          "en_JP"
        ];
        NSUserDictionaryReplacementItems = [ ];
        WebAutomaticSpellingCorrectionEnabled = false;
      };

      "com.apple.driver.AppleBluetoothMultitouch.trackpad" = {
        TrackpadCornerSecondaryClick = 0;
        TrackpadFiveFingerPinchGesture = 2;
        TrackpadFourFingerHorizSwipeGesture = 2;
        TrackpadFourFingerPinchGesture = 2;
        TrackpadFourFingerVertSwipeGesture = 2;
        TrackpadThreeFingerHorizSwipeGesture = 0;
        TrackpadThreeFingerTapGesture = 2;
        TrackpadThreeFingerVertSwipeGesture = 0;
        TrackpadTwoFingerDoubleTapGesture = 1;
        TrackpadTwoFingerFromRightEdgeSwipeGesture = 3;
      };

      "com.apple.screensaver" = {
        askForPassword = 1;
        askForPasswordDelay = 5;
      };

      "com.apple.finder" = {
        FXArrangeGroupViewBy = "Name";
        FXPreferredGroupBy = "Kind";
      };

      "com.apple.spotlight" = {
        orderedItems = [
          { enabled = true; name = "APPLICATIONS"; }
          { enabled = true; name = "MENU_CONVERSION"; }
          { enabled = true; name = "MENU_EXPRESSION"; }
          { enabled = true; name = "MENU_DEFINITION"; }
          { enabled = false; name = "MENU_SPOTLIGHT_SUGGESTIONS"; }
          { enabled = false; name = "SYSTEM_PREFS"; }
          { enabled = false; name = "DOCUMENTS"; }
          { enabled = false; name = "DIRECTORIES"; }
          { enabled = false; name = "PRESENTATIONS"; }
          { enabled = false; name = "SPREADSHEETS"; }
          { enabled = false; name = "PDF"; }
          { enabled = false; name = "MESSAGES"; }
          { enabled = false; name = "CONTACT"; }
          { enabled = false; name = "EVENT_TODO"; }
          { enabled = false; name = "IMAGES"; }
          { enabled = false; name = "BOOKMARKS"; }
          { enabled = false; name = "MUSIC"; }
          { enabled = false; name = "MOVIES"; }
          { enabled = false; name = "FONTS"; }
          { enabled = false; name = "MENU_OTHER"; }
          { enabled = false; name = "SOURCE"; }
        ];
      };

      "com.apple.inputmethod.Kotoeri" = {
        JIMPrefAutocorrectionKey = true;
        JIMPrefCandidateWindowFontKey = "TsukuARdGothic-Bold";
        JIMPrefConvertWithPunctuationKey = 0;
        JIMPrefFullWidthNumeralCharactersKey = false;
        JIMPrefLiveConversionKey = false;
      };

      "com.apple.DictionaryServices" = {
        DCSActiveDictionaries = [
          "com.apple.dictionary.ja-en.WISDOM"
          "com.apple.dictionary.NOAD"
          "com.apple.dictionary.OAWT"
          "com.apple.dictionary.ja.Daijirin"
        ];
      };
    };
  };
}
