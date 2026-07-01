
module.exports = {
  root: true,
  env: {
    browser: false,
    es2021: true
  },
  extends: ['eslint:recommended'],
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module'
  },
  plugins: ['@typescript-eslint'],
  rules: {
    // 禁止使用 var
    'no-var': 'error',
    // 要求使用 const 或 let
    'prefer-const': 'error',
    // 禁止未使用的变量
    'no-unused-vars': 'off',
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    // 禁止 console（除了 warn 和 error）
    'no-console': ['warn', { allow: ['warn', 'error'] }],
    // 要求分号
    'semi': ['error', 'always'],
    // 引号使用单引号
    'quotes': ['error', 'single', { avoidEscape: true }],
    // 缩进 2 个空格
    'indent': ['error', 2],
    // 禁止尾随空格
    'no-trailing-spaces': 'error',
    // 逗号风格
    'comma-style': ['error', 'last'],
    // 禁止尾随逗号
    'comma-dangle': ['error', 'never'],
    // 大括号风格
    'brace-style': ['error', '1tbs', { allowSingleLine: true }],
    // 空格使用
    'space-before-function-paren': ['error', 'never'],
    'space-before-blocks': ['error', 'always'],
    'keyword-spacing': ['error', { before: true, after: true }]
  }
};
