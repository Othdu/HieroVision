import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../bloc/hieroglyphic_bloc.dart';
import '../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';

// Egyptian theme colors
const egyptianGold = Color(0xFFD4AF37);
const egyptianBlue = Color(0xFF1034A6);
const papyrusBeige = Color(0xFFF7E7CE);
const sandStone = Color(0xFFE7C697);
const pharaohBlue = Color(0xFF0F1E4E);
const deepGold = Color(0xFFC19B3C);

class HomeScreen extends StatelessWidget {
  final Function(Locale) onLocaleChange;
  
  const HomeScreen({super.key, required this.onLocaleChange});

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      if (context.mounted) {
        context.read<HieroglyphicBloc>().add(
          ProcessImageEvent(File(image.path)),
        );
      }
    }
  }

  void _openSettings(BuildContext context) async {
    final result = await Navigator.push<SharedPreferences>(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    
    if (result != null) {
      final languageCode = result.getString('language') ?? 'en';
      onLocaleChange(Locale(languageCode));
      context.read<HieroglyphicBloc>().updateLocale(languageCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textDirection = Localizations.localeOf(context).languageCode == 'ar' 
        ? TextDirection.rtl 
        : TextDirection.ltr;
    
    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: papyrusBeige,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: pharaohBlue.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Row(
                      children: [
                        _buildHeaderIcon(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    'HieroVision',
                                    speed: const Duration(milliseconds: 200),
                                    textStyle: GoogleFonts.cinzel(
                                      color: pharaohBlue,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                                totalRepeatCount: 1,
                                displayFullTextOnTap: true,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 12,
                                    color: egyptianGold,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Ancient Wisdom Unveiled',
                                    style: GoogleFonts.crimsonText(
                                      color: pharaohBlue.withOpacity(0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        _buildSettingsButton(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: BlocBuilder<HieroglyphicBloc, HieroglyphicState>(
          builder: (context, state) {
            return Container(
              decoration: BoxDecoration(
                image: state is HieroglyphicProcessing || state is HieroglyphicSuccess ? DecorationImage(
                  image: const AssetImage('assets/images/grunge-background.jpg'),
                  fit: BoxFit.cover,
                  opacity: 0.04,
                  colorFilter: ColorFilter.mode(
                    pharaohBlue.withOpacity(0.08),
                    BlendMode.multiply,
                  ),
                ) : null,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildMainContainer(state, localizations),
                    ),
                    _buildSelectImageButton(state, context, localizations),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            egyptianGold.withOpacity(0.15),
            deepGold.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: egyptianGold.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.translate_rounded,
        color: egyptianGold,
        size: 22,
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: pharaohBlue.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: Icon(
          Icons.settings_outlined,
          color: pharaohBlue.withOpacity(0.7),
          size: 22,
        ),
        onPressed: () => _openSettings(context),
        splashRadius: 22,
      ),
    );
  }

  Widget _buildMainContainer(HieroglyphicState state, AppLocalizations localizations) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: egyptianGold.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: pharaohBlue.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _buildContent(state, localizations),
      ),
    );
  }

  Widget _buildSelectImageButton(HieroglyphicState state, BuildContext context, AppLocalizations localizations) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      transform: Matrix4.identity()
        ..translate(0.0, state is HieroglyphicProcessing ? 8.0 : 0.0),
      child: Container(
        height: 56,
        margin: const EdgeInsets.only(top: 16, bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              egyptianGold,
              deepGold,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: egyptianGold.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: egyptianGold.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: state is! HieroglyphicProcessing
                ? () => _pickImage(context)
                : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_rounded,
                    size: 24,
                    color: Colors.white.withOpacity(0.95),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      localizations.selectImage,
                      style: GoogleFonts.cinzel(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        color: Colors.white.withOpacity(0.95),
                      ),
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(HieroglyphicState state, AppLocalizations localizations) {
    if (state is HieroglyphicProcessing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: egyptianGold.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  color: egyptianGold,
                  strokeWidth: 2,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Decoding Hieroglyphs...',
              style: GoogleFonts.cinzel(
                fontSize: 16,
                color: pharaohBlue,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    } else if (state is HieroglyphicSuccess) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    egyptianGold.withOpacity(0.12),
                    deepGold.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: egyptianGold.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: egyptianGold,
                size: 42,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: egyptianGold.withOpacity(0.25),
                    width: 1.5,
                  ),
                ),
              ),
              child: Text(
                localizations.translation,
                style: GoogleFonts.cinzel(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: pharaohBlue,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    sandStone.withOpacity(0.2),
                    sandStone.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: egyptianGold.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Text(
                state.text,
                style: GoogleFonts.crimsonText(
                  fontSize: 18,
                  color: pharaohBlue.withOpacity(0.9),
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      );
    } else if (state is HieroglyphicError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.red.withOpacity(0.15),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade700,
                  size: 42,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Error: ${state.message}',
                style: GoogleFonts.cinzel(
                  color: Colors.red.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  sandStone.withOpacity(0.2),
                  sandStone.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: egyptianGold.withOpacity(0.25),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: pharaohBlue.withOpacity(0.04),
                  blurRadius: 16,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              size: 64,
              color: egyptianGold.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: egyptianGold.withOpacity(0.25),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              localizations.selectToTranslate,
              style: GoogleFonts.cinzel(
                fontSize: 16,
                color: pharaohBlue.withOpacity(0.9),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
} 