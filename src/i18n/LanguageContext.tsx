import React, { createContext, useContext, useState, useEffect } from 'react';
import { SupportedLanguage, Translations, SUPPORTED_LANGUAGES, LanguageInfo } from './types';
import { en } from './translations/en';
import { hi } from './translations/hi';
import { ta } from './translations/ta';

const LANGUAGE_STORAGE_KEY = 'onionsure_language_v1';

const translationsMap: Record<SupportedLanguage, Translations> = {
  en,
  hi,
  ta,
};

interface LanguageContextType {
  language: SupportedLanguage;
  setLanguage: (lang: SupportedLanguage) => void;
  t: Translations;
  languages: LanguageInfo[];
  interpolate: (text: string, params: Record<string, string | number>) => string;
}

const LanguageContext = createContext<LanguageContextType | undefined>(undefined);

export function interpolate(text: string, params: Record<string, string | number>): string {
  if (!text) return '';
  return Object.entries(params).reduce(
    (acc, [key, val]) => acc.replace(new RegExp(`\\{${key}\\}`, 'g'), String(val)),
    text
  );
}

export const LanguageProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [language, setLanguageState] = useState<SupportedLanguage>(() => {
    try {
      const saved = localStorage.getItem(LANGUAGE_STORAGE_KEY);
      if (saved === 'en' || saved === 'hi' || saved === 'ta') {
        return saved;
      }
    } catch (e) {
      console.warn('Could not read saved language preference:', e);
    }
    return 'en';
  });

  const setLanguage = (newLang: SupportedLanguage) => {
    setLanguageState(newLang);
    try {
      localStorage.setItem(LANGUAGE_STORAGE_KEY, newLang);
    } catch (e) {
      console.warn('Could not save language preference:', e);
    }
  };

  // Sync html lang attribute
  useEffect(() => {
    document.documentElement.lang = language;
  }, [language]);

  const value: LanguageContextType = {
    language,
    setLanguage,
    t: translationsMap[language] || en,
    languages: SUPPORTED_LANGUAGES,
    interpolate,
  };

  return <LanguageContext.Provider value={value}>{children}</LanguageContext.Provider>;
};

export function useLanguage(): LanguageContextType {
  const context = useContext(LanguageContext);
  if (!context) {
    throw new Error('useLanguage must be used within a LanguageProvider');
  }
  return context;
}
