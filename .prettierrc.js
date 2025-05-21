import prettierPluginXQuery from 'prettier-plugin-xquery';

/**
 * @type {import('prettier').Config}
 */
const config = {
    useTabs: true,
    singleQuote: true,
    printWidth: 120,
    plugins: [prettierPluginXQuery],
};

export default config;