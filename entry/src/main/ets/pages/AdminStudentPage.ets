import { ApiClient } from '../services/ApiClient';
import { StudentListItem } from '../models/ApiModels';

@Component
export struct AdminStudentPage {
  @Link page: number;
  @State students: StudentListItem[] = [];
  @State loading: boolean = false;
  @State errorText: string = '';
  @State total: number = 0;
  @State keyword: string = '';
  @State statusFilter: string = '';
  @State enabledFilter: string = '';
  @State filterVisible: boolean = false;
  @State gradeFilter: string = '';
  @State departmentFilter: string = '';
  @State majorFilter: string = '';
  @State classFilter: string = '';
  @State selectedStudent: StudentListItem | null = null;

  aboutToAppear(): void { void this.load(); }

  private async load(): Promise<void> {
    this.loading = true; this.errorText = '';
    try {
      const grade = this.gradeFilter.length > 0 ? Number(this.gradeFilter) : undefined;
      const departmentId = this.departmentFilter.length > 0 ? Number(this.departmentFilter) : undefined;
      const majorId = this.majorFilter.length > 0 ? Number(this.majorFilter) : undefined;
      const classGroupId = this.classFilter.length > 0 ? Number(this.classFilter) : undefined;
      const activated = this.enabledFilter === '已激活' ? true : this.enabledFilter === '未激活' ? false : undefined;
      const result = await ApiClient.getStudents(this.page, 20, this.keyword, this.statusFilter, undefined, grade, departmentId, majorId, classGroupId, activated);
      this.students = result.items; this.total = result.total;
    } catch (error) { this.errorText = error instanceof Error ? error.message : '加载学生数据失败'; }
    finally { this.loading = false; }
  }

  private statusText(status: string): string {
    if (status === 'ENROLLED') return '在读';
    if (status === 'SUSPENDED') return '休学';
    if (status === 'GRADUATED') return '毕业';
    if (status === 'WITHDRAWN') return '退学';
    return status;
  }

  private cycleStatus(): void {
    const values: string[] = ['', 'ENROLLED', 'SUSPENDED', 'GRADUATED', 'WITHDRAWN'];
    const index = values.indexOf(this.statusFilter);
    this.statusFilter = values[(index + 1) % values.length];
    void this.load();
  }

  private cycleEnabled(): void {
    const values: string[] = ['', '已激活', '未激活'];
    const index = values.indexOf(this.enabledFilter);
    this.enabledFilter = values[(index + 1) % values.length];
    void this.load();
  }

  private cycleValue(current: string, values: string[]): string {
    const index = values.indexOf(current);
    return values[(index + 1) % values.length];
  }

  private applyFilter(): void {
    this.filterVisible = false;
    void this.load();
  }

  private async openDetail(item: StudentListItem): Promise<void> {
    try {
      this.selectedStudent = await ApiClient.getStudent(item.id);
    } catch (_) {
      this.selectedStudent = item;
      this.showToast('详情接口暂时不可用，已显示列表数据');
    }
  }

  @Builder
  private row(item: StudentListItem) {
    Row() {
      Text(item.studentNo).fontSize(13).fontColor('#17324D').layoutWeight(1)
      Text(this.statusText(item.status)).fontSize(13).fontColor('#516B80').width(55).textAlign(TextAlign.Center)
      Text(item.activated === false ? '未激活' : '已激活').fontSize(12).fontColor(item.activated === false ? '#9A6B2F' : '#176B87').width(62).textAlign(TextAlign.Center)
      Text('详情').fontSize(13).fontColor('#176B87').width(48).textAlign(TextAlign.Center).onClick(() => { void this.openDetail(item); })
    }.width('100%').padding({ top: 14, bottom: 14, left: 8, right: 8 }).border({ width: { bottom: 1 }, color: '#E8EFF2' })
  }

  @Builder
  private detailDialog() {
    if (this.selectedStudent !== null) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#661D3445')
        Column({ space: 12 }) {
          Row() {
            Text('学生详情').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
            Text(this.statusText(this.selectedStudent.status)).fontSize(12).fontColor('#176B87').backgroundColor('#E4F2F5').padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(10)
            Text(this.selectedStudent.activated === false ? '未激活' : '已激活').fontSize(12).fontColor(this.selectedStudent.activated === false ? '#9A6B2F' : '#176B87').backgroundColor('#E4F2F5').padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(10).margin({ left: 6 })
            Text('×').fontSize(26).fontColor('#718096').margin({ left: 8 }).onClick(() => this.selectedStudent = null)
          }
          Row() { Text('姓名').width(72).fontColor('#718096'); Text(this.selectedStudent.name || '暂无数据').fontColor('#17324D').layoutWeight(1) }
          Row() { Text('学号').width(72).fontColor('#718096'); Text(this.selectedStudent.studentNo || '暂无数据').fontColor('#17324D').layoutWeight(1) }
          Row() { Text('学院').width(72).fontColor('#718096'); Text(this.selectedStudent.departmentName ?? '暂无数据').fontColor('#17324D').layoutWeight(1) }
          Row() { Text('专业').width(72).fontColor('#718096'); Text(this.selectedStudent.majorName ?? '暂无数据').fontColor('#17324D').layoutWeight(1) }
          Row() { Text('班级').width(72).fontColor('#718096'); Text(this.selectedStudent.classGroup?.name ?? '暂无数据').fontColor('#17324D').layoutWeight(1) }
          Row() { Text('电话').width(72).fontColor('#718096'); Text(this.selectedStudent.phone ?? '暂无数据').fontColor('#17324D').layoutWeight(1) }
          Row({ space: 8 }) {
            Button('编辑资料').layoutWeight(1).backgroundColor('#DCEFF2').fontColor('#176B87').onClick(() => this.showToast('编辑表单下一步接入'))
            Button(this.selectedStudent.enabled === false ? '启用账号' : '停用账号').layoutWeight(1).backgroundColor('#197C93').fontColor(Color.White).onClick(() => this.showToast('账号操作下一步接入'))
          }
          Row({ space: 8 }) {
            Button('重置密码').layoutWeight(1).backgroundColor('#DCEFF2').fontColor('#176B87').onClick(() => this.showToast('密码操作下一步接入'))
            Button('删除学生').layoutWeight(1).backgroundColor('#F7E5E5').fontColor('#B04A4A').onClick(() => this.showToast('删除操作需二次确认'))
          }
        }.width('86%').padding(20).backgroundColor(Color.White).borderRadius(20)
      }.width('100%').height('100%')
    }
  }

  @Builder
  private filterDialog() {
    if (this.filterVisible) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000')
        Column({ space: 14 }) {
          Row() { Text('筛选学生').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1); Text('×').fontSize(26).fontColor('#718096').onClick(() => this.filterVisible = false) }
          Text('一级筛选 · 学号结构 4-2-2-2-2').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#31566D').width('100%')
          Row({ space: 8 }) {
            TextInput({ placeholder: '年级', text: this.gradeFilter }).width('34%').height(40).fontSize(16).backgroundColor('#EAF5F7').borderRadius(9).maxLength(4).onChange((value: string) => this.gradeFilter = value)
            TextInput({ placeholder: '学院', text: this.departmentFilter }).width('18%').height(40).fontSize(14).backgroundColor('#EAF5F7').borderRadius(9).maxLength(2).onChange((value: string) => this.departmentFilter = value)
            TextInput({ placeholder: '专业', text: this.majorFilter }).width('18%').height(40).fontSize(14).backgroundColor('#EAF5F7').borderRadius(9).maxLength(2).onChange((value: string) => this.majorFilter = value)
            TextInput({ placeholder: '班级', text: this.classFilter }).width('18%').height(40).fontSize(14).backgroundColor('#EAF5F7').borderRadius(9).maxLength(2).onChange((value: string) => this.classFilter = value)
          }
          Text('二级筛选').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#516B80').width('100%')
          Row({ space: 8 }) {
            Button(this.statusFilter === '' ? '学籍状态' : this.statusText(this.statusFilter)).layoutWeight(1).backgroundColor('#EAF5F7').fontColor('#31566D').onClick(() => this.statusFilter = this.cycleValue(this.statusFilter, ['', 'ENROLLED', 'SUSPENDED', 'GRADUATED']))
            Button(this.enabledFilter || '激活状态').layoutWeight(1).backgroundColor('#EAF5F7').fontColor('#31566D').onClick(() => this.enabledFilter = this.cycleValue(this.enabledFilter, ['', '已激活', '未激活']))
            Button('确认筛选').layoutWeight(1).backgroundColor('#197C93').fontColor(Color.White).onClick(() => this.applyFilter())
          }
        }.width('92%').padding(18).backgroundColor('#F7FCFD').borderRadius(20)
      }.width('100%').height('100%')
    }
  }

  private showToast(message: string): void { try { this.getUIContext().getPromptAction().showToast({ message, duration: 2200 }); } catch (_) {} }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('‹').fontSize(32).fontColor('#176B87').width(42).onClick(() => this.page = 0)
          Text('学生管理').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
          Text(`${this.total}人`).fontSize(13).fontColor('#718096')
        }.width('100%').padding({ left: 18, right: 20, top: 18, bottom: 10 })
        Row({ space: 8 }) {
          TextInput({ placeholder: '输入学号搜索', text: this.keyword }).layoutWeight(1).height(42).backgroundColor(Color.White).borderRadius(10)
            .onChange((value: string) => this.keyword = value).onSubmit(() => this.load())
          Button('新增').height(40).backgroundColor('#176B87').onClick(() => this.showToast('新增学生表单下一步接入'))
          Button('筛选').height(40).backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => this.filterVisible = true)
        }.width('100%').padding({ left: 20, right: 20, bottom: 8 })
        Row() {
          Text('学号').layoutWeight(1).fontSize(13).fontColor('#516B80'); Text('学籍').width(55).textAlign(TextAlign.Center).fontSize(13).fontColor('#516B80'); Text('激活').width(62).textAlign(TextAlign.Center).fontSize(13).fontColor('#516B80'); Text('详情').width(48).textAlign(TextAlign.Center).fontSize(13).fontColor('#516B80')
        }.width('100%').padding({ left: 28, right: 28, top: 12, bottom: 12 }).backgroundColor('#E4F2F5')
        Text(`当前筛选：${this.statusFilter === '' ? '全部学籍' : this.statusText(this.statusFilter)} · ${this.enabledFilter === '' ? '全部账号' : this.enabledFilter}`).fontSize(12).fontColor('#8999A4').width('100%').padding({ left: 20, top: 8, bottom: 4 })
        if (this.loading) { LoadingProgress().color('#176B87').margin({ top: 30 }) }
        else if (this.errorText.length > 0) { Text(this.errorText).fontSize(14).fontColor('#C04A4A').margin({ top: 30 }) }
        else { List() { ForEach(this.students, (item: StudentListItem) => { ListItem() { this.row(item) } }) }.width('100%').layoutWeight(1).padding({ left: 20, right: 20, bottom: 20 }) }
      }.width('100%').height('100%').backgroundColor('#EDF5F7')
      this.detailDialog()
      this.filterDialog()
    }.width('100%').height('100%')
  }
}
