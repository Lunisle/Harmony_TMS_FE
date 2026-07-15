import { UserInfo } from '../models/ApiModels';

@Component
export struct AdminWorkbenchPage {
  @Prop user: UserInfo;
  @Link page: number;

  private showMessage(message: string): void {
    try { this.getUIContext().getPromptAction().showToast({ message, duration: 2200 }); } catch (_) {}
  }

  @Builder
  private adminRow(icon: string, title: string, description: string, tag: string, active: boolean) {
    Row({ space: 14 }) {
      Text(icon).fontSize(25).fontColor(active ? '#176B87' : '#8999A4').textAlign(TextAlign.Center).width(52).height(52)
        .padding({ top: 11 }).backgroundColor(active ? '#E4F2F5' : '#EEF1F3').borderRadius(16)
      Column({ space: 5 }) {
        Text(title).fontSize(18).fontWeight(FontWeight.Bold).fontColor(active ? '#17324D' : '#718096').width('100%')
        Text(description).fontSize(13).fontColor(active ? '#718096' : '#9AA6AD').maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis }).width('100%')
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      Column({ space: 4 }) {
        Text(tag).fontSize(11).fontColor(active ? '#176B87' : '#8999A4').padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(active ? '#E4F2F5' : '#EEF1F3').borderRadius(10)
        Text('›').fontSize(24).fontColor(active ? '#9AACB8' : '#B5C0C5')
      }.width(88).alignItems(HorizontalAlign.Center)
    }.width('100%').padding(16).backgroundColor(Color.White).borderRadius(16)
      .shadow({ radius: 10, color: active ? '#10000000' : '#06000000', offsetY: 3 })
      .onClick(() => {
        if (!active) { this.showMessage(`${title}正在开发中`); }
        else if (title === '学生管理') { this.page = 1; }
        else if (title === '教师管理') { this.page = 2; }
        else if (title === '教室管理') { this.page = 3; }
        else if (title === '课程管理') { this.page = 4; }
        else if (title === '教室申请审批') { this.page = 6; }
        else if (title === '考试安排') { this.page = 7; }
        else { this.showMessage(`${title}入口已准备，下一步接入接口`); }
      })
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text('管理员工作台').fontSize(26).fontWeight(FontWeight.Bold).fontColor('#17324D').width('100%')
        Text(this.user.department ? `${this.user.department.name} · ${this.user.role}` : `全局管理 · ${this.user.role}`)
          .fontSize(13).fontColor('#718096').width('100%').margin({ bottom: 8 })

        Text('数据管理').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#29445A').width('100%')
        this.adminRow('生', '学生管理', '维护学生档案和激活状态', '基础数据', true)
        this.adminRow('师', '教师管理', '维护教师档案和账号关联', '基础数据', true)
        this.adminRow('课', '课程管理', '维护课程、学分和负责人', '基础数据', true)
        this.adminRow('室', '教室管理', '维护校区、楼栋和教室状态', '基础数据', true)

        Text('其他服务').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#29445A').width('100%').margin({ top: 10 })
        this.adminRow('审', '教室申请审批', '审批教师和学生的教室使用申请', '教务管理员', true)
        this.adminRow('考', '考试安排', '维护学期考试、考场和监考教师', '教务管理', true)

        Text('开发中').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#718096').width('100%').margin({ top: 10 })
        this.adminRow('院', '部门管理', '维护学院、系部及部门编码', '开发中', false)
        this.adminRow('专', '专业管理', '维护专业和所属部门', '开发中', false)
        this.adminRow('班', '班级管理', '维护年级、班级和辅导员', '开发中', false)
        this.adminRow('期', '学期管理', '维护学期和当前学期状态', '开发中', false)
        this.adminRow('权', '用户与权限', '管理账号、角色和启停状态', '开发中', false)
        this.adminRow('志', '操作日志', '查询管理员操作和审计记录', '开发中', false)
      }.width('100%').padding({ left: 20, right: 20, top: 24, bottom: 20 })
    }.layoutWeight(1).width('100%')
  }
}
