import js from '@eslint/js'
import globals from 'globals'
import reactHooks from 'eslint-plugin-react-hooks'
import reactRefresh from 'eslint-plugin-react-refresh'
import { defineConfig, globalIgnores } from 'eslint/config'

export default defineConfig([
  globalIgnores(['dist']),
  {
    files: ['**/*.{js,jsx}'],
    extends: [
      js.configs.recommended,
      reactHooks.configs.flat.recommended,
      reactRefresh.configs.vite,
    ],
    languageOptions: {
      ecmaVersion: 2020,
      globals: globals.browser,
      parserOptions: {
        ecmaVersion: 'latest',
        ecmaFeatures: { jsx: true },
        sourceType: 'module',
      },
    },
    rules: {
      // Note: This repo doesn't include eslint-plugin-react, so JSX usage
      // won't mark imports as "used" (e.g. <motion.div />). Keep this as a
      // warning to avoid blocking builds/CI while still surfacing issues.
      'no-unused-vars': ['warn', { varsIgnorePattern: '^[A-Z_]' }],
      // This is a dev-only ergonomics rule; keep it off to avoid forcing
      // awkward file splits for contexts/hooks.
      'react-refresh/only-export-components': 'off',
    },
  },
  {
    files: ['vite.config.js'],
    languageOptions: {
      globals: { ...globals.browser, ...globals.node },
    },
  },
])
