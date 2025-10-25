import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import '../l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  final bool showAsBottomSheet;
  final VoidCallback? onLanguageChanged;
  
  const LanguageSelector({
    Key? key,
    this.showAsBottomSheet = false,
    this.onLanguageChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (showAsBottomSheet) {
      return _buildBottomSheet(context);
    } else {
      return _buildDropdown(context);
    }
  }

  Widget _buildDropdown(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        final l10n = AppLocalizations.of(context);
        final currentLanguageKey = localizationService.getCurrentLanguageKey();
        
        return DropdownButtonHideUnderline(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButton<String>(
              value: currentLanguageKey,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              isExpanded: true,
              items: localizationService.getSupportedLanguageKeys().map((String languageKey) {
                return DropdownMenuItem<String>(
                  value: languageKey,
                  child: Row(
                    children: [
                      Text(
                        localizationService.getLanguageFlag(languageKey),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          localizationService.getLanguageName(languageKey),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newLanguageKey) {
                if (newLanguageKey != null) {
                  localizationService.setLocale(newLanguageKey);
                  onLanguageChanged?.call();
                }
              },
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildBottomSheet(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        final l10n = AppLocalizations.of(context);
        final currentLanguageKey = localizationService.getCurrentLanguageKey();
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                l10n!.selectLanguage,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              
              // Language options
              ...localizationService.getSupportedLanguageKeys().map((String languageKey) {
                final isSelected = languageKey == currentLanguageKey;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        localizationService.setLocale(languageKey);
                        Navigator.pop(context);
                        onLanguageChanged?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected ? Colors.orange.shade50 : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? Colors.orange : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              localizationService.getLanguageFlag(languageKey),
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                localizationService.getLanguageName(languageKey),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? Colors.orange.shade700 : Colors.black87,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: Colors.orange.shade700,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  static void showLanguageBottomSheet(BuildContext context, {VoidCallback? onLanguageChanged}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguageSelector(
        showAsBottomSheet: true,
        onLanguageChanged: onLanguageChanged,
      ),
    );
  }
}

// Widget compacto para exibir idioma atual com bandeira
class CurrentLanguageDisplay extends StatelessWidget {
  final VoidCallback? onTap;
  final bool showLabel;
  
  const CurrentLanguageDisplay({
    Key? key,
    this.onTap,
    this.showLabel = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        final l10n = AppLocalizations.of(context);
        final currentLanguageKey = localizationService.getCurrentLanguageKey();
        
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    localizationService.getLanguageFlag(currentLanguageKey),
                    style: const TextStyle(fontSize: 18),
                  ),
                  if (showLabel) ...[
                    const SizedBox(width: 6),
                    Text(
                      localizationService.getLanguageName(currentLanguageKey).split(' ')[0],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}