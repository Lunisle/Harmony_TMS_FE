import { UserInfo } from '../models/ApiModels';

@Component
export struct WorkbenchPage {
  @Prop user: UserInfo;
  @Link page: number;

  private showMessage(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2200 });
    } catch (_) {
    }
  }

  @Builder
  private serviceRow(icon: string, title: string, description: string, tag: string, active: boolean) {
    Row({ space: 14 }) {
      Text(icon)
        .fontSize(25)
        .fontWeight(FontWeight.Medium)
        .fontColor('#176B87')
        .textAlign(TextAlign.Center)
        .width(52)
        .height(52)
        .padding({ top: 11 })
        .backgroundColor('#E4F2F5')
        .borderRadius(16)
      Column({ space: 5 }) {
        Text(title)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#17324D')
          .width('100%')
        Text(description)
          .fontSize(13)
          .fontColor('#718096')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Column({ space: 5 }) {
        Text(tag)
          .fontSize(11)
          .fontColor(active ? '#176B87' : '#8999A4')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(active ? '#E4F2F5' : '#EEF1F3')
          .borderRadius(10)
        Text('›')
          .fontSize(24)
          .fontColor('#9AACB8')
          .width('100%')
          .textAlign(TextAlign.Center)
      }
      .width(72)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 10, color: '#10000000', offsetY: 3 })
    .onClick(() => {
      if (title === '教室申请') {
        this.page = 1;
      } else {
        this.showMessage(active ? `${title}功能即将接入` : `${title}开发中`);
      }
    })
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        Text('工作台')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#17324D')
          .width('100%')
        Text('全部教学服务入口将按账号角色逐步开放')
          .fontSize(13)
          .fontColor('#718096')
          .width('100%')
          .margin({ bottom: 8 })

        Text('学生服务')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#29445A')
          .width('100%')
        this.serviceRow('考', '考试查询', '查看考试安排与提醒', '学生', true)
        this.serviceRow('室', '教室申请', '申请可用教学场地', '学生', true)
        this.serviceRow('修', '重修申请', '提交课程重修申请', '学生', true)
        this.serviceRow('升', '专升本报名', '查看报名资格与进度', '学生', true)

        Text('教师服务')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#29445A')
          .width('100%')
          .margin({ top: 10 })
        this.serviceRow('课', '授课资料', '管理课程标准与课件', '教师 · 开发中', false)
        this.serviceRow('核', '考核方式', '提交考核方式申请', '教师 · 开发中', false)
        this.serviceRow('调', '调课申请', '提交调课与补课安排', '教师 · 开发中', false)
        this.serviceRow('志', '教学日志', '记录授课内容与出勤', '教师 · 开发中', false)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 24, bottom: 20 })
    }
    .layoutWeight(1)
    .width('100%')
  }
}
