export interface Announcement {
  id: number;
  title: string;
  date: string;
  category: string;
  summary: string;
  content: string;
}

export const STATIC_ANNOUNCEMENTS: Announcement[] = [
  {
    id: 1,
    title: '2026 年秋季学期教学工作安排通知',
    date: '2026.07.24',
    category: '教学安排',
    summary: '请同学们关注新学期课程安排和选课时间。',
    content: '新学期教学准备工作已启动，请同学们及时查看课程安排，按照学院通知完成选课和开学准备。具体安排以后续通知为准。'
  },
  {
    id: 2,
    title: '期末考试考场规则与注意事项',
    date: '2026.07.18',
    category: '考试通知',
    summary: '请提前确认考试时间、地点并遵守考场纪律。',
    content: '参加考试前请携带有效证件，提前熟悉考场位置。考试期间请遵守考场纪律，保持安静，按监考教师要求完成考试。'
  },
  {
    id: 3,
    title: '教学场地申请系统服务说明',
    date: '2026.07.12',
    category: '服务公告',
    summary: '教学场地申请入口已开放，可在工作台提交申请。',
    content: '教学场地申请服务将逐步开放。学生和教师可以通过工作台进入相应服务入口，查看申请要求和办理进度。'
  }
];
