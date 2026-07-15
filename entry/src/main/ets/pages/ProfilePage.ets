import { common } from '@kit.AbilityKit';
import { ApiClient } from '../services/ApiClient';
import { SessionStore } from '../services/SessionStore';
import { UserInfo } from '../models/ApiModels';

@Component
export struct ProfilePage {
  @Prop user: UserInfo;
  @Link loggedIn: boolean;

  private async logout(): Promise<void> {
    try {
      ApiClient.clearToken();
      await SessionStore.clear(getContext(this) as common.UIAbilityContext);
      this.loggedIn = false;
      this.getUIContext().getPromptAction().showToast({ message: '已退出登录', duration: 2200 });
    } catch (_) {
      this.loggedIn = false;
    }
  }

  @Builder
  private detail(label: string, value: string) {
    Row() {
      Text(label).fontSize(14).fontColor('#718096')
      Text(value).fontSize(15).fontColor('#29445A').fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: 11, bottom: 11 })
    .border({ width: { bottom: 1 }, color: '#EDF1F3' })
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        Text('我的')
          .fontSize(26).fontWeight(FontWeight.Bold).fontColor('#17324D').width('100%')
        Column({ space: 10 }) {
          Text(this.user.displayName ?? this.user.student?.name ?? this.user.teacher?.name ?? this.user.username)
            .fontSize(23).fontWeight(FontWeight.Bold).fontColor('#17324D').width('100%')
          Text(this.user.roleLabel ?? (this.user.role === 'STUDENT' ? '学生' : this.user.role === 'TEACHER' ? '教师' : '管理员'))
            .fontSize(13).fontColor('#176B87').width('100%')
        }
        .width('100%').padding(20).backgroundColor('#E4F2F5').borderRadius(18)
        Column() {
          this.detail('账号', this.user.username)
          if (this.user.student !== null) {
            this.detail('学号', this.user.student?.studentNo ?? '—')
            this.detail('班级', this.user.student?.classGroupName ?? this.user.student?.className ?? '—')
            this.detail('年级', `${this.user.student?.grade ?? '—'}`)
            this.detail('学籍状态', this.user.student?.status ?? '—')
          } else if (this.user.teacher !== null) {
            this.detail('工号', this.user.teacher?.employeeNo ?? '—')
            this.detail('部门', this.user.teacher?.departmentName ?? '—')
            this.detail('教师类型', this.user.teacher?.teacherType ?? '—')
            this.detail('职称', this.user.teacher?.title ?? '—')
          } else {
            this.detail('角色', this.user.roleLabel ?? this.user.role)
            this.detail('账号状态', this.user.enabled === false ? '已停用' : '正常')
          }
        }
        .width('100%').padding({ left: 18, right: 18 }).backgroundColor(Color.White).borderRadius(18)
        .shadow({ radius: 12, color: '#12000000', offsetY: 4 })
        Button('退出登录')
          .width('100%').height(50).backgroundColor('#DDE7EC').fontColor('#17324D')
          .onClick(async () => await this.logout())
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 24, bottom: 20 })
    }
    .layoutWeight(1)
    .width('100%')
  }
}
