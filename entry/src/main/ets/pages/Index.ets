import { common } from '@kit.AbilityKit';
import { ApiClient } from '../services/ApiClient';
import { SessionStore } from '../services/SessionStore';
import { LoginRequest, RegisterRequest, UserInfo } from '../models/ApiModels';
import { BottomTabBar } from '../components/BottomTabBar';
import { HomePage } from './HomePage';
import { WorkbenchPage } from './WorkbenchPage';
import { AdminWorkbenchPage } from './AdminWorkbenchPage';
import { AdminStudentPage } from './AdminStudentPage';
import { ProfilePage } from './ProfilePage';

@Entry
@Component
struct Index {
  @State activeTab: number = 0;
  @State loginUsername: string = '';
  @State loginPassword: string = '';
  @State studentNo: string = '';
  @State studentName: string = '';
  @State registerPassword: string = '';
  @State confirmPassword: string = '';
  @State loading: boolean = false;
  @State appReady: boolean = false;
  @State loggedIn: boolean = false;
  @State selectedTab: number = 0;
  @State adminPage: number = 0;
  @State currentUser: UserInfo = { id: 0, username: '', role: '', student: null };

  aboutToAppear(): void {
    void this.restoreSession();
  }

  private getAbilityContext(): common.UIAbilityContext {
    return getContext(this) as common.UIAbilityContext;
  }

  private showMessage(message: string): void {
    try {
      this.getUIContext().getPromptAction().showToast({ message: message, duration: 2500 });
    } catch (_) {
    }
  }

  private errorMessage(error: Object): string {
    return error instanceof Error ? error.message : '操作失败，请稍后重试';
  }

  private async restoreSession(): Promise<void> {
    try {
      const session = await SessionStore.load(this.getAbilityContext());
      if (session) {
        ApiClient.setToken(session.token);
        this.currentUser = await ApiClient.getCurrentUser();
        this.loggedIn = true;
      }
    } catch (_) {
      ApiClient.clearToken();
      await SessionStore.clear(this.getAbilityContext());
    } finally {
      this.appReady = true;
    }
  }

  private async handleLogin(): Promise<void> {
    if (!this.loginUsername.trim() || !this.loginPassword) {
      this.showMessage('请输入账号和密码');
      return;
    }
    this.loading = true;
    try {
      const request: LoginRequest = { username: this.loginUsername.trim(), password: this.loginPassword };
      const result = await ApiClient.login(request);
      await SessionStore.save(this.getAbilityContext(), result.token, result.user);
      this.currentUser = result.user;
      this.selectedTab = 0;
      this.loggedIn = true;
      this.loginPassword = '';
      this.showMessage('登录成功');
    } catch (error) {
      this.showMessage(this.errorMessage(error as Object));
    } finally {
      this.loading = false;
    }
  }

  private async handleRegister(): Promise<void> {
    if (!this.studentNo.trim() || !this.studentName.trim()) {
      this.showMessage('请输入学号和姓名');
      return;
    }
    if (this.registerPassword.length < 8) {
      this.showMessage('密码至少需要8位');
      return;
    }
    if (this.registerPassword !== this.confirmPassword) {
      this.showMessage('两次输入的密码不一致');
      return;
    }
    this.loading = true;
    try {
      const request: RegisterRequest = {
        studentNo: this.studentNo.trim(), name: this.studentName.trim(), password: this.registerPassword
      };
      const result = await ApiClient.register(request);
      this.loginUsername = result.studentNo;
      this.loginPassword = '';
      this.activeTab = 0;
      this.registerPassword = '';
      this.confirmPassword = '';
      this.showMessage(result.message);
    } catch (error) {
      this.showMessage(this.errorMessage(error as Object));
    } finally {
      this.loading = false;
    }
  }

  @Builder
  private brandHeader() {
    Column({ space: 8 }) {
      Text('教学过程管理系统').fontSize(28).fontWeight(FontWeight.Bold).fontColor('#17324D')
      Text('Teaching Process Management').fontSize(14).fontColor('#6B7C8F')
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }

  @Builder
  private authTabSelector() {
    Row() {
      Text('登录').fontSize(16).fontWeight(this.activeTab === 0 ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.activeTab === 0 ? '#176B87' : '#718096').textAlign(TextAlign.Center).layoutWeight(1)
        .padding({ top: 14, bottom: 14 }).border({ width: { bottom: this.activeTab === 0 ? 3 : 0 }, color: '#176B87' })
        .onClick(() => this.activeTab = 0)
      Text('学生注册').fontSize(16).fontWeight(this.activeTab === 1 ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.activeTab === 1 ? '#176B87' : '#718096').textAlign(TextAlign.Center).layoutWeight(1)
        .padding({ top: 14, bottom: 14 }).border({ width: { bottom: this.activeTab === 1 ? 3 : 0 }, color: '#176B87' })
        .onClick(() => this.activeTab = 1)
    }
    .width('100%')
  }

  @Builder
  private loginForm() {
    Column({ space: 16 }) {
      TextInput({ placeholder: '管理员账号或学生学号', text: this.loginUsername })
        .height(52).backgroundColor('#F5F8FA').borderRadius(12).onChange((value: string) => this.loginUsername = value)
      TextInput({ placeholder: '密码', text: this.loginPassword }).type(InputType.Password)
        .height(52).backgroundColor('#F5F8FA').borderRadius(12).onChange((value: string) => this.loginPassword = value)
      Button(this.loading ? '登录中…' : '登录').width('100%').height(50).backgroundColor('#176B87').fontSize(17)
        .enabled(!this.loading).onClick(async () => await this.handleLogin())
      Text('学生首次使用请先切换到“学生注册”激活账号')
        .fontSize(13).fontColor('#718096').textAlign(TextAlign.Center).width('100%')
    }
    .width('100%').padding({ top: 22 })
  }

  @Builder
  private registerForm() {
    Column({ space: 14 }) {
      TextInput({ placeholder: '学号', text: this.studentNo }).height(50).backgroundColor('#F5F8FA').borderRadius(12)
        .onChange((value: string) => this.studentNo = value)
      TextInput({ placeholder: '姓名（需与管理员导入档案一致）', text: this.studentName }).height(50)
        .backgroundColor('#F5F8FA').borderRadius(12).onChange((value: string) => this.studentName = value)
      TextInput({ placeholder: '设置密码（至少8位）', text: this.registerPassword }).type(InputType.Password).height(50)
        .backgroundColor('#F5F8FA').borderRadius(12).onChange((value: string) => this.registerPassword = value)
      TextInput({ placeholder: '确认密码', text: this.confirmPassword }).type(InputType.Password).height(50)
        .backgroundColor('#F5F8FA').borderRadius(12).onChange((value: string) => this.confirmPassword = value)
      Button(this.loading ? '提交中…' : '注册并激活').width('100%').height(50).backgroundColor('#176B87').fontSize(17)
        .enabled(!this.loading).onClick(async () => await this.handleRegister())
    }
    .width('100%').padding({ top: 20 })
  }

  @Builder
  private authView() {
    Scroll() {
      Column() {
        this.brandHeader()
        Column() {
          this.authTabSelector()
          if (this.activeTab === 0) {
            this.loginForm()
          } else {
            this.registerForm()
          }
        }
        .width('100%').margin({ top: 30 }).padding({ left: 22, right: 22, bottom: 24 })
        .backgroundColor(Color.White).borderRadius(20).shadow({ radius: 20, color: '#14000000', offsetY: 8 })
      }
      .width('100%').padding({ left: 24, right: 24, top: 60, bottom: 32 })
    }
    .width('100%').height('100%').backgroundColor('#EDF5F7')
  }

  @Builder
  private workspaceView() {
    Column() {
      if (this.selectedTab === 0) {
        HomePage({ user: this.currentUser })
      } else if (this.selectedTab === 1) {
        if (this.currentUser.role === 'ADMIN' || this.currentUser.role === 'ACADEMIC' || this.currentUser.role === 'DEPARTMENT_ADMIN') {
          if (this.adminPage === 1) {
            AdminStudentPage({ page: $adminPage })
          } else {
            AdminWorkbenchPage({ user: this.currentUser, page: $adminPage })
          }
        } else {
          WorkbenchPage({ user: this.currentUser })
        }
      } else {
        ProfilePage({ user: this.currentUser, loggedIn: $loggedIn })
      }
      BottomTabBar({ selectedIndex: $selectedTab })
    }
    .width('100%').height('100%').backgroundColor('#EDF5F7')
  }

  build() {
    if (!this.appReady) {
      Column({ space: 16 }) {
        LoadingProgress().color('#176B87')
        Text('正在验证登录状态').fontSize(15).fontColor('#718096')
      }
      .width('100%').height('100%').justifyContent(FlexAlign.Center).backgroundColor('#EDF5F7')
    } else if (!this.loggedIn) {
      this.authView()
    } else {
      this.workspaceView()
    }
  }
}
