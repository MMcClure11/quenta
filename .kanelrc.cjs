const { makeKyselyHook, kyselyCamelCaseHook } = require('kanel-kysely')
const { generateIndexFile } = require('kanel')

/*
 * Generated Database.ts is not compatible with TS verbatimModuleSyntax
 * https://github.com/kristiandupont/kanel/issues/436
 */
const supportVerbatimModuleSyntaxHook = (filePath, lines) => {
  if (filePath.endsWith('Database.ts')) {
    lines.pop()
    lines.push('export type { Database as default };')
  }
  return lines
}

module.exports = {
  // ... your config here.
  schemas: ['public'],
  enumStyle: 'enum',
  outputPath: 'src/lib/__generated__/kanel',
  preDeleteOutputFolder: true,

  preRenderHooks: [makeKyselyHook(), kyselyCamelCaseHook, generateIndexFile],
  postRenderHooks: [supportVerbatimModuleSyntaxHook],
}
