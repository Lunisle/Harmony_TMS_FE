export interface AnnouncementContent {
  id: number;
  title: string;
  date: string;
  category: string;
  summary: string;
  content: string;
  cover: string;
}

export const ANNOUNCEMENTS: AnnouncementContent[] = [
  { id: 1, title: '2026年秋季学期教学工作安排通知', date: '2026.07.24', category: '教学安排', summary: '请关注新学期课程安排、教学周次与开学准备事项。', content: '2026年秋季学期教学准备工作已经启动。请师生及时查看课程安排，按学院通知完成选课、备课及开学准备。课程、考试与教室安排以系统后续发布的信息为准。', cover: 'classroom' },
  { id: 2, title: '期末考试考场规则与注意事项', date: '2026.07.18', category: '考试通知', summary: '请提前确认考试时间、地点，并遵守考场纪律。', content: '参加考试前请携带有效证件，提前熟悉考场位置。考试开始后请服从监考教师安排，保持安静，不得携带与考试无关的资料和电子设备进入考场。', cover: 'library' },
  { id: 3, title: '教学场地申请系统服务说明', date: '2026.07.12', category: '服务公告', summary: '学生和教师可在工作台提交教学场地申请。', content: '教学场地申请服务已开放。申请人可在工作台选择可申请教室、填写使用时段、人数及用途。提交后由教务管理员审批，请留意“我的申请”中的处理进度。', cover: 'campus' },
  { id: 4, title: '暑期教学楼开放时间调整', date: '2026.07.08', category: '校园服务', summary: '暑期部分教学楼开放时间将作调整，请合理安排学习与教学活动。', content: '根据暑期校园运行安排，部分教学楼及自习区域的开放时间将调整。涉及实验教学、课程补课或学生活动的，请提前通过系统确认可用场地。', cover: 'campus' },
  { id: 5, title: '2026级新生学籍信息核验提醒', date: '2026.07.03', category: '学籍服务', summary: '请相关管理员及时核对新生班级、专业与联系方式。', content: '新生基础信息导入后，请学院及班级管理人员及时核验学号、姓名、年级、专业和班级信息。如发现异常，请在学生管理模块完成更正并保留必要说明。', cover: 'classroom' },
  { id: 6, title: '教师调课申请办理说明', date: '2026.06.28', category: '教学服务', summary: '调课申请需由授课教师本人提交，并说明调整原因。', content: '授课教师可在工作台提交调课申请，选择本人负责课程和对应班级组，填写课时及申请原因。申请提交后由管理员审批，驳回意见会在申请详情中显示。', cover: 'classroom' },
  { id: 7, title: '图书馆期末复习专区开放', date: '2026.06.22', category: '校园服务', summary: '图书馆新增期末复习座位与学习支持服务。', content: '期末复习期间，图书馆将延长部分阅览区域开放时间，并设置安静自习区和课程资料查阅专区。请遵守馆内秩序，共同维护良好的学习环境。', cover: 'library' },
  { id: 8, title: '系统维护窗口通知', date: '2026.06.16', category: '系统通知', summary: '系统将于维护窗口进行例行升级，部分服务可能短暂不可用。', content: '为提升教学过程管理系统的稳定性，系统将在维护窗口进行例行升级。维护期间登录、申请和查询服务可能短暂受影响，请避开该时段提交重要业务。', cover: 'campus' }
];
