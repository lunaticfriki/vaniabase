import globals from "globals";
import pluginJs from "@eslint/js";
import tseslint from "typescript-eslint";
import eslintConfigPrettier from "eslint-config-prettier";

export default [
  {files: ["**/*.{js,mjs,cjs,ts}"]},
  {languageOptions: { globals: globals.browser, parserOptions: { projectService: { allowDefaultProject: ['*.js', '*.mjs', '*.cjs'] }, tsconfigRootDir: import.meta.dirname } }},
  pluginJs.configs.recommended,
  ...tseslint.configs.recommendedTypeChecked,
  {
    files: ["eslint.config.js"],
    ...tseslint.configs.disableTypeChecked,
  },
  eslintConfigPrettier,
  {
    ignores: ["dist/"],
  },
  {
    rules: {
      "@typescript-eslint/no-unused-vars": [
        "error",
        {
          argsIgnorePattern: "^_",
          varsIgnorePattern: "^_",
          caughtErrorsIgnorePattern: "^_",
        },
      ],
    },
  },
];
