# AGENTS

<skills_system priority="1">

## Available Skills

<!-- SKILLS_TABLE_START -->
<usage>
When users ask you to perform tasks, check if any of the available skills below can help complete the task more effectively. Skills provide specialized capabilities and domain knowledge.

How to use skills:
- Invoke: Bash("openskills read <skill-name>")
- The skill content will load with detailed instructions on how to complete the task
- Base directory provided in output for resolving bundled resources (references/, scripts/, assets/)

Usage notes:
- Only use skills listed in <available_skills> below
- Do not invoke a skill that is already loaded in your context
- Each skill invocation is stateless
</usage>

<available_skills>

<skill>
<name>changelog-automation</name>
<description>Automate changelog generation from commits, PRs, and releases following Keep a Changelog format. Use when setting up release workflows, generating release notes, or standardizing commit conventions.</description>
<location>global</location>
</skill>

<skill>
<name>obsidian-daily-note</name>
<description>管理 Obsidian 每日工作日志的完整工具集. 用于创建、更新、删除 Obsidian 目录下的工作日志文件, 支持任务管理、任务合并、状态更新、工作日志记录等功能. 使用场景包括: (1) 创建或更新指定日期的工作日志, (2) 添加、完成、删除每日任务, (3) 记录工作日志条目, (4) 自动合并相同任务避免重复, (5) 按需创建月份目录和日志文件. 日志存储在 /Users/zhangsan/Documents/obsidian/dailywork/DailyNote/2026 目录下, 按月份组织 (2026-01 到 2026-12), 文件命名格式为 YYYY-MM-DD.md.</description>
<location>global</location>
</skill>

</available_skills>
<!-- SKILLS_TABLE_END -->

</skills_system>
