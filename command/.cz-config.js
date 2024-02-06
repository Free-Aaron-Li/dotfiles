'use strict';

module.exports = {

  types: [
    { value: '🚧  WIP',         name : '🚧  WIP:            开发中' },
    { value: '✨  feat',        name : '✨  feat:           新功能' },
    { value: '🎼  improvement', name : '🎼  improvement:    对现有特性的提升' },
    { value: '🔦  fix',         name : '🔦  fix:            修复Bug' },
    { value: '🛠  refactor',    name : '🛠  refactor:        既不修改bug也不添加特性的代码更改' },
    { value: '📚  docs',        name : '📚  docs:           仅文档更改' },
    { value: '🧪  test',        name : '🧪  test:           添加缺少的测试或更正现有测试' },
    { value: '⚙   config',      name : '⚙   config:         修改或添加配置文件' },
    { value: '💅  style',       name : '💅  style:          不影响代码含义的更改（空白、格式设置、缺失分号等）' },
    { value: '📈  perf',        name : '📈  perf:           改进性能的代码更改' },
    { value: '🔧  ci',          name : '🔧  ci:             自动化流程配置修改' },
    { value: '⏪  revert',      name : '⏪  revert:         回滚到上一个版本' },
    { value: '🧶  chore',       name : '🧶  chore:          对构建过程或或辅助工具和库（如文档）的更改' },
    { value: '🪜  build',       name : '🪜  build:          改变构建流程、新增依赖库、工具等（例如webpack、gulp、npm修改）'},
    { value: '🪓  delete',       name : '🪓  delete:        删除功能或文件' },
    { value: '🪛  modify',       name : '🪛  modify:        修改功能' },
  ],

  // scopes: [{ name: 'accounts' }, { name: 'admin' }, { name: 'exampleScope' }, { name: 'changeMe' }],

  // allowTicketNumber: false,
  // isTicketNumberRequired: false,
  // ticketNumberPrefix: 'TICKET-',
  // ticketNumberRegExp: '\\d{1,5}',

  messages: {
    type: '选择一种你的提交类型:',
    scope: '选择修改涉及范围 (可选):',
    // used if allowCustomScopes is true
    customScope: '请输入本次改动的范围（如：功能、模块等）:',
    subject: '简短说明:\n',
    body: '详细说明，使用"|"分隔开可以换行(可选)：\n',
    breaking: '非兼容性，破坏性变化说明 (可选):\n',
    footer: '关联关闭的issue，例如：#31, #34(可选):\n',
    confirmCommit: '确定提交说明?'
  },

  allowCustomScopes: true,
  allowBreakingChanges: ["feat", "fix"],  // 仅在feat、fix时填写破坏性更改
  subjectLimit: 100, // limit subject length
  breaklineChar: '|',  // 设置body和footer中的换行符
};

