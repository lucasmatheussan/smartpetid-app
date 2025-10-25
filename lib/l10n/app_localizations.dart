import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('pt'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt', 'AO'),
    Locale('pt', 'BR'),
    Locale('pt', 'PT'),
    Locale('ru'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'SmartPet ID'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Identificação Inteligente para Pets'**
  String get appSubtitle;

  /// No description provided for @loginTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Acesse sua conta'**
  String get loginSubtitle;

  /// No description provided for @username.
  ///
  /// In pt, this message translates to:
  /// **'Nome de usuário'**
  String get username;

  /// No description provided for @password.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get password;

  /// No description provided for @login.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get login;

  /// No description provided for @register.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar'**
  String get register;

  /// No description provided for @registerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar Conta'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre-se para começar'**
  String get registerSubtitle;

  /// No description provided for @fullName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In pt, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In pt, this message translates to:
  /// **'Telefone'**
  String get phone;

  /// No description provided for @confirmPassword.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar senha'**
  String get confirmPassword;

  /// No description provided for @createAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tem uma conta?'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Não tem uma conta?'**
  String get dontHaveAccount;

  /// No description provided for @homeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get homeTitle;

  /// No description provided for @scanTitle.
  ///
  /// In pt, this message translates to:
  /// **'Escanear'**
  String get scanTitle;

  /// No description provided for @registerPetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar Pet'**
  String get registerPetTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @petName.
  ///
  /// In pt, this message translates to:
  /// **'Nome do pet'**
  String get petName;

  /// No description provided for @petSpecies.
  ///
  /// In pt, this message translates to:
  /// **'Espécie'**
  String get petSpecies;

  /// No description provided for @petBreed.
  ///
  /// In pt, this message translates to:
  /// **'Raça'**
  String get petBreed;

  /// No description provided for @petAge.
  ///
  /// In pt, this message translates to:
  /// **'Idade'**
  String get petAge;

  /// No description provided for @petDescription.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get petDescription;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @selectImage.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar imagem'**
  String get selectImage;

  /// No description provided for @takePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Tirar foto'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In pt, this message translates to:
  /// **'Escolher da galeria'**
  String get chooseFromGallery;

  /// No description provided for @language.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @portuguese.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get portuguese;

  /// No description provided for @english.
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In pt, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @french.
  ///
  /// In pt, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @russian.
  ///
  /// In pt, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @chinese.
  ///
  /// In pt, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @success.
  ///
  /// In pt, this message translates to:
  /// **'Sucesso'**
  String get success;

  /// No description provided for @error.
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get error;

  /// No description provided for @warning.
  ///
  /// In pt, this message translates to:
  /// **'Aviso'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In pt, this message translates to:
  /// **'Informação'**
  String get info;

  /// No description provided for @loadingAnimals.
  ///
  /// In pt, this message translates to:
  /// **'Carregando animais...'**
  String get loadingAnimals;

  /// No description provided for @tryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get tryAgain;

  /// No description provided for @noAnimalsRegistered.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum animal registrado'**
  String get noAnimalsRegistered;

  /// No description provided for @registerFirstAnimal.
  ///
  /// In pt, this message translates to:
  /// **'Registre o primeiro animal para vê-lo aqui'**
  String get registerFirstAnimal;

  /// No description provided for @nameNotProvided.
  ///
  /// In pt, this message translates to:
  /// **'Nome não fornecido'**
  String get nameNotProvided;

  /// No description provided for @years.
  ///
  /// In pt, this message translates to:
  /// **'anos'**
  String get years;

  /// No description provided for @dog.
  ///
  /// In pt, this message translates to:
  /// **'Cão'**
  String get dog;

  /// No description provided for @cat.
  ///
  /// In pt, this message translates to:
  /// **'Gato'**
  String get cat;

  /// No description provided for @animal.
  ///
  /// In pt, this message translates to:
  /// **'Animal'**
  String get animal;

  /// No description provided for @sessionExpired.
  ///
  /// In pt, this message translates to:
  /// **'Sessão expirada. Faça login novamente.'**
  String get sessionExpired;

  /// No description provided for @errorLoadingPets.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar animais'**
  String get errorLoadingPets;

  /// No description provided for @myAnimals.
  ///
  /// In pt, this message translates to:
  /// **'Meus Animais'**
  String get myAnimals;

  /// No description provided for @petDetails.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes do Animal'**
  String get petDetails;

  /// No description provided for @errorLoadingPetDetails.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar detalhes'**
  String get errorLoadingPetDetails;

  /// No description provided for @connectionErrorDetails.
  ///
  /// In pt, this message translates to:
  /// **'Erro de conexão'**
  String get connectionErrorDetails;

  /// No description provided for @breedNotProvided.
  ///
  /// In pt, this message translates to:
  /// **'Raça não fornecida'**
  String get breedNotProvided;

  /// No description provided for @high.
  ///
  /// In pt, this message translates to:
  /// **'Alta'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In pt, this message translates to:
  /// **'Média'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In pt, this message translates to:
  /// **'Baixa'**
  String get low;

  /// No description provided for @photoQuality.
  ///
  /// In pt, this message translates to:
  /// **'Qualidade da Foto'**
  String get photoQuality;

  /// No description provided for @noPhotosAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma foto disponível'**
  String get noPhotosAvailable;

  /// No description provided for @notEvaluated.
  ///
  /// In pt, this message translates to:
  /// **'Não avaliado'**
  String get notEvaluated;

  /// No description provided for @information.
  ///
  /// In pt, this message translates to:
  /// **'Informações'**
  String get information;

  /// No description provided for @species.
  ///
  /// In pt, this message translates to:
  /// **'Espécie'**
  String get species;

  /// No description provided for @breed.
  ///
  /// In pt, this message translates to:
  /// **'Raça'**
  String get breed;

  /// No description provided for @age.
  ///
  /// In pt, this message translates to:
  /// **'Idade'**
  String get age;

  /// No description provided for @ownerContact.
  ///
  /// In pt, this message translates to:
  /// **'Contato do Dono'**
  String get ownerContact;

  /// No description provided for @contact.
  ///
  /// In pt, this message translates to:
  /// **'Contato'**
  String get contact;

  /// No description provided for @ownerId.
  ///
  /// In pt, this message translates to:
  /// **'ID do Dono'**
  String get ownerId;

  /// No description provided for @registration.
  ///
  /// In pt, this message translates to:
  /// **'Registro'**
  String get registration;

  /// No description provided for @registrationDate.
  ///
  /// In pt, this message translates to:
  /// **'Data de Registro'**
  String get registrationDate;

  /// No description provided for @description.
  ///
  /// In pt, this message translates to:
  /// **'Descrição'**
  String get description;

  /// No description provided for @notProvided.
  ///
  /// In pt, this message translates to:
  /// **'Não fornecido'**
  String get notProvided;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, digite o nome de usuário'**
  String get pleaseEnterUsername;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, digite a senha'**
  String get pleaseEnterPassword;

  /// No description provided for @pleaseEnterName.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, digite o nome'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, digite o email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, digite um email válido'**
  String get pleaseEnterValidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In pt, this message translates to:
  /// **'A senha deve ter pelo menos 6 caracteres'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In pt, this message translates to:
  /// **'As senhas não coincidem'**
  String get passwordsDoNotMatch;

  /// No description provided for @fillDataToRegister.
  ///
  /// In pt, this message translates to:
  /// **'Preencha os dados para se cadastrar'**
  String get fillDataToRegister;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, digite o nome completo'**
  String get pleaseEnterFullName;

  /// No description provided for @usernameMinLength.
  ///
  /// In pt, this message translates to:
  /// **'Nome de usuário deve ter pelo menos 3 caracteres'**
  String get usernameMinLength;

  /// No description provided for @phoneOptional.
  ///
  /// In pt, this message translates to:
  /// **'Telefone (opcional)'**
  String get phoneOptional;

  /// No description provided for @passwordMinLength.
  ///
  /// In pt, this message translates to:
  /// **'Senha deve ter pelo menos 6 caracteres'**
  String get passwordMinLength;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, confirme a senha'**
  String get pleaseConfirmPassword;

  /// No description provided for @loginError.
  ///
  /// In pt, this message translates to:
  /// **'Erro no login'**
  String get loginError;

  /// No description provided for @connectionError.
  ///
  /// In pt, this message translates to:
  /// **'Erro de conexão'**
  String get connectionError;

  /// No description provided for @errorTitle.
  ///
  /// In pt, this message translates to:
  /// **'Erro'**
  String get errorTitle;

  /// No description provided for @okButton.
  ///
  /// In pt, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @loginButton.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginButton;

  /// No description provided for @noAccount.
  ///
  /// In pt, this message translates to:
  /// **'Não tem uma conta?'**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In pt, this message translates to:
  /// **'Cadastre-se'**
  String get signUp;

  /// No description provided for @animalDetails.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes do Animal'**
  String get animalDetails;

  /// No description provided for @sessionExpiredLoginAgain.
  ///
  /// In pt, this message translates to:
  /// **'Sessão expirada. Faça login novamente'**
  String get sessionExpiredLoginAgain;

  /// No description provided for @registeredAnimals.
  ///
  /// In pt, this message translates to:
  /// **'Animais Registrados'**
  String get registeredAnimals;

  /// No description provided for @registerFirstAnimalToSeeHere.
  ///
  /// In pt, this message translates to:
  /// **'Registre seu primeiro animal para vê-lo aqui'**
  String get registerFirstAnimalToSeeHere;

  /// No description provided for @settings.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settings;

  /// No description provided for @selectLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Selecione o idioma'**
  String get selectLanguage;

  /// No description provided for @appInfo.
  ///
  /// In pt, this message translates to:
  /// **'Informações do App'**
  String get appInfo;

  /// No description provided for @version.
  ///
  /// In pt, this message translates to:
  /// **'Versão'**
  String get version;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'pt',
        'en',
        'es',
        'fr',
        'ru',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'AO':
            return AppLocalizationsPtAo();
          case 'BR':
            return AppLocalizationsPtBr();
          case 'PT':
            return AppLocalizationsPtPt();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
