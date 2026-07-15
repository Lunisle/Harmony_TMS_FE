import { ApiClient } from '../services/ApiClient';
import { ScheduleChangeListItem, ScheduleChangeMutationRequest, CourseSummary, TeacherListItem, StudentOptionClassGroup, UserInfo } from '../models/ApiModels';

@Component
export struct ScheduleChangePage {
  @Prop user: UserInfo;
  @Link page: number;
  @State items: ScheduleChangeListItem[] = [];
  @State selected: ScheduleChangeListItem | null = null;
  @State formVisible: boolean = false;
  @State detailVisible: boolean = false;
  @State editingId: number = 0;
  @State teacherId: string = '';
  @State courseId: string = '';
  @State classGroupId: string = '';
  @State hours: string = '1';
  @State reason: string = '';
  @State status: string = 'PENDING';
  @State decisionVisible: boolean = false;
  @State decisionStatus: string = '';
  @State decisionComment: string = '';
  @State loading: boolean = false;
  @State courses: CourseSummary[] = [];
  @State teachers: TeacherListItem[] = [];
  @State classGroups: StudentOptionClassGroup[] = [];

  aboutToAppear(): void { void this.initialize(); }
  private async initialize(): Promise<void> { await this.loadOptions(); await this.load(); }
  private async loadOptions(): Promise<void> { try { this.courses = await ApiClient.getCourses(); this.teachers = (await ApiClient.getTeachers(1, 100)).items; if (this.user.role === 'TEACHER' && this.user.teacherId !== undefined && this.user.teacherId !== null) { this.teachers = this.teachers.filter((v: TeacherListItem) => v.id === this.user.teacherId); } this.classGroups = await ApiClient.getClassGroups(); } catch (error) { this.showToast(error instanceof Error ? error.message : '加载调课选项失败'); } }
  private cycleId(current: string, values: number[]): string { if (values.length === 0) return ''; const id = Number(current); const index = values.indexOf(id); return `${index < 0 || index >= values.length - 1 ? values[0] : values[index + 1]}`; }
  private courseLabel(): string { const item = this.courses.find((v: CourseSummary) => v.id === Number(this.courseId)); return item ? `${item.code} ${item.name}` : '选择课程'; }
  private teacherLabel(): string { const item = this.teachers.find((v: TeacherListItem) => v.id === Number(this.teacherId)); return item ? item.name : '选择教师'; }
  private classGroupLabel(): string { const item = this.classGroups.find((v: StudentOptionClassGroup) => v.id === Number(this.classGroupId)); return item ? item.name : '选择班级组'; }

  private async load(): Promise<void> {
    this.loading = true;
    try { this.items = (await ApiClient.getScheduleChanges(1, 100)).items; }
    catch (error) { this.showToast(error instanceof Error ? error.message : '加载调课申请失败'); }
    finally { this.loading = false; }
  }

  private async openDetail(item: ScheduleChangeListItem): Promise<void> {
    try { this.selected = await ApiClient.getScheduleChange(item.id); } catch (_) { this.selected = item; }
    this.detailVisible = true;
  }

  private statusText(value: string): string {
    if (value === 'PENDING') return '待审批';
    if (value === 'APPROVED') return '已通过';
    if (value === 'REJECTED') return '已驳回';
    if (value === 'CANCELLED') return '已取消';
    return '草稿';
  }

  private showToast(message: string): void { try { this.getUIContext().getPromptAction().showToast({ message, duration: 2200 }); } catch (_) {} }
  private canSubmit(): boolean { return this.user.role === 'TEACHER' || this.user.role === 'ADMIN'; }
  private canApprove(): boolean { return this.user.role === 'DEPARTMENT_ADMIN' || this.user.role === 'ACADEMIC' || this.user.role === 'ADMIN'; }

  private openCreate(): void {
    this.editingId = 0; this.teacherId = this.user.role === 'TEACHER' && this.user.teacherId ? `${this.user.teacherId}` : ''; this.courseId = ''; this.classGroupId = ''; this.hours = '1'; this.reason = ''; this.formVisible = true;
  }

  private openEdit(item: ScheduleChangeListItem): void {
    this.editingId = item.id;
    this.teacherId = `${item.teacherId}`;
    this.courseId = `${item.courseId}`;
    this.classGroupId = `${item.classGroupId}`;
    this.hours = `${item.hours}`;
    this.reason = item.reason;
    this.detailVisible = false;
    this.formVisible = true;
  }

  private async save(): Promise<void> {
    const data: ScheduleChangeMutationRequest = { teacherId: Number(this.teacherId), courseId: Number(this.courseId), classGroupId: Number(this.classGroupId), hours: Number(this.hours), reason: this.reason.trim(), status: 'PENDING' };
    if (!Number.isInteger(data.teacherId) || !Number.isInteger(data.courseId) || !Number.isInteger(data.classGroupId) || data.teacherId < 1 || data.courseId < 1 || data.classGroupId < 1 || data.hours < 0.5 || data.reason.length === 0) { this.showToast('请完整填写教师、课程、班级、课时和原因'); return; }
    try {
      const editing = this.editingId > 0;
      if (editing) {
        const updateData: ScheduleChangeMutationRequest = { teacherId: data.teacherId, courseId: data.courseId, classGroupId: data.classGroupId, hours: data.hours, reason: data.reason };
        await ApiClient.updateScheduleChange(this.editingId, updateData);
      } else { await ApiClient.createScheduleChange(data); }
      this.formVisible = false; this.editingId = 0; await this.load(); this.showToast(editing ? '调课申请已更新' : '调课申请已提交');
    }
    catch (error) { this.showToast(error instanceof Error ? error.message : '提交调课申请失败'); }
  }

  private async updateStatus(item: ScheduleChangeListItem, status: string, comment?: string): Promise<void> {
    try { await ApiClient.updateScheduleChangeStatus(item.id, status, comment); await this.load(); this.showToast(status === 'APPROVED' ? '调课申请已通过' : '调课申请已驳回'); }
    catch (error) { this.showToast(error instanceof Error ? error.message : '审批操作失败'); }
  }

  private openDecision(item: ScheduleChangeListItem, status: string): void {
    if (status === 'REJECTED') {
      this.selected = item;
      this.decisionStatus = status;
      this.decisionComment = '';
      this.decisionVisible = true;
    } else {
      void this.updateStatus(item, status);
    }
  }

  private async submitDecision(): Promise<void> {
    if (this.selected === null) return;
    if (this.decisionComment.trim().length === 0) { this.showToast('驳回时必须填写审批意见'); return; }
    this.decisionVisible = false;
    await this.updateStatus(this.selected, this.decisionStatus, this.decisionComment.trim());
    this.selected = null;
  }

  private async remove(item: ScheduleChangeListItem): Promise<void> {
    try { await ApiClient.deleteScheduleChange(item.id); await this.load(); this.showToast('调课申请已删除'); }
    catch (error) { this.showToast(error instanceof Error ? error.message : '删除失败'); }
  }

  private selectOptions(placeholder: string, labels: string[]): SelectOption[] {
    const options: SelectOption[] = [{ value: placeholder }];
    labels.forEach((label: string) => options.push({ value: label }));
    return options;
  }

  private selectedIndex(value: string, ids: number[]): number {
    const index = ids.indexOf(Number(value));
    return index < 0 ? 0 : index + 1;
  }

  @Builder
  private requiredLabel(label: string) {
    Row({ space: 3 }) {
      Text('*').fontSize(15).fontColor('#D94B4B').fontWeight(FontWeight.Bold)
      Text(label).fontSize(13).fontColor('#516B80')
    }.width('100%').justifyContent(FlexAlign.Start)
  }

  @Builder
  private row(item: ScheduleChangeListItem) {
    Column({ space: 7 }) {
      Row() { Column({ space: 3 }) { Text(item.courseName ?? `课程 ${item.courseId}`).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#17324D'); Text(`${item.teacherName ?? `教师 ${item.teacherId}`} · ${item.classGroupName ?? `班级 ${item.classGroupId}`}`).fontSize(12).fontColor('#718096') }.layoutWeight(1).alignItems(HorizontalAlign.Start); Text(this.statusText(item.status)).fontSize(12).fontColor('#176B87').backgroundColor('#E4F2F5').padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(9) }
      Text(`${item.hours} 课时 · ${item.reason}`).fontSize(13).fontColor('#516B80').width('100%').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
      Button('查看详情').width('100%').backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => { void this.openDetail(item); })
      if (item.status === 'PENDING' && this.canApprove()) { Row({ space: 8 }) { Button('通过').layoutWeight(1).backgroundColor('#DDF2EA').fontColor('#167C68').onClick(() => this.openDecision(item, 'APPROVED')); Button('驳回').layoutWeight(1).backgroundColor('#F7E5E5').fontColor('#B04A4A').onClick(() => this.openDecision(item, 'REJECTED')) }.width('100%') }
      if (item.status === 'DRAFT' && this.canSubmit()) { Row({ space: 8 }) { Button('编辑草稿').layoutWeight(1).backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => this.openEdit(item)); Button('删除草稿').layoutWeight(1).backgroundColor('#F7E5E5').fontColor('#B04A4A').onClick(() => { void this.remove(item); }) }.width('100%') }
    }.width('100%').padding(15).backgroundColor(Color.White).borderRadius(15).margin({ bottom: 10 })
  }

  @Builder
  private formDialog() {
    if (this.formVisible) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000').onClick(() => this.formVisible = false)
        Scroll() {
          Column({ space: 12 }) {
            Row() {
              Text(this.editingId > 0 ? '编辑调课申请' : '新建调课申请').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
              Text('×').fontSize(26).fontColor('#718096').onClick(() => this.formVisible = false)
            }.width('100%')
            this.requiredLabel('授课教师')
            if (this.user.role === 'TEACHER') {
              Text(this.teacherLabel()).width('100%').height(44).padding({ left: 14, right: 14 }).backgroundColor('#EAF5F7').borderRadius(10).fontColor('#31566D')
                .textAlign(TextAlign.Start)
            } else {
              Select(this.selectOptions('请选择授课教师', this.teachers.map((item: TeacherListItem) => item.name))).selected(this.selectedIndex(this.teacherId, this.teachers.map((item: TeacherListItem) => item.id))).width('100%').height(44)
                .backgroundColor('#EAF5F7').fontColor('#31566D').onSelect((index: number) => this.teacherId = index > 0 ? `${this.teachers[index - 1].id}` : '')
            }
            this.requiredLabel('课程')
            Select(this.selectOptions('请选择课程', this.courses.map((item: CourseSummary) => `${item.code} · ${item.name}`))).selected(this.selectedIndex(this.courseId, this.courses.map((item: CourseSummary) => item.id))).width('100%').height(44)
              .backgroundColor('#EAF5F7').fontColor('#31566D').onSelect((index: number) => this.courseId = index > 0 ? `${this.courses[index - 1].id}` : '')
            this.requiredLabel('班级组')
            Select(this.selectOptions('请选择班级组', this.classGroups.map((item: StudentOptionClassGroup) => item.name))).selected(this.selectedIndex(this.classGroupId, this.classGroups.map((item: StudentOptionClassGroup) => item.id))).width('100%').height(44)
              .backgroundColor('#EAF5F7').fontColor('#31566D').onSelect((index: number) => this.classGroupId = index > 0 ? `${this.classGroups[index - 1].id}` : '')
            this.requiredLabel('调课课时')
            TextInput({ placeholder: '请输入调课课时，例如 1', text: this.hours }).type(InputType.Number).height(44).backgroundColor('#F1F6F8').borderRadius(10)
              .onChange((value: string) => this.hours = value)
            this.requiredLabel('申请原因')
            TextArea({ placeholder: '请说明调课原因', text: this.reason }).height(88).backgroundColor('#F1F6F8').borderRadius(10)
              .onChange((value: string) => this.reason = value)
            Text('带 * 的项目为必填；提交后由有审批权限的管理员处理。').fontSize(12).fontColor('#8999A4').width('100%')
            Row({ space: 10 }) {
              Button('取消').layoutWeight(1).backgroundColor('#E8EFF2').fontColor('#516B80').onClick(() => this.formVisible = false)
              Button(this.editingId > 0 ? '保存' : '提交').layoutWeight(1).backgroundColor('#176B87').fontColor(Color.White).onClick(() => { void this.save(); })
            }
          }.width('100%').padding(20).backgroundColor(Color.White).borderRadius(20)
        }.width('88%').height('84%')
      }.width('100%').height('100%')
    }
  }

  @Builder
  private detailDialog() {
    if (this.detailVisible && this.selected !== null) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000').onClick(() => this.detailVisible = false)
        Column({ space: 12 }) {
          Row() { Text('调课申请详情').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1); Text('×').fontSize(26).fontColor('#718096').onClick(() => this.detailVisible = false) }.width('100%')
          Text(`课程：${this.selected.courseName ?? this.selected.courseId}`).fontSize(15).fontColor('#17324D').width('100%')
          Text(`教师：${this.selected.teacherName ?? this.selected.teacherId}`).fontSize(14).fontColor('#516B80').width('100%')
          Text(`班级：${this.selected.classGroupName ?? this.selected.classGroupId}`).fontSize(14).fontColor('#516B80').width('100%')
          Text(`课时：${this.selected.hours}`).fontSize(14).fontColor('#516B80').width('100%')
          Text(`原因：${this.selected.reason}`).fontSize(14).fontColor('#516B80').width('100%').maxLines(4).textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(`状态：${this.statusText(this.selected.status)}`).fontSize(14).fontColor('#176B87').width('100%')
          if (this.selected.status === 'DRAFT' && this.canSubmit()) { Button('编辑草稿').width('100%').backgroundColor('#176B87').fontColor(Color.White).onClick(() => this.openEdit(this.selected as ScheduleChangeListItem)) }
          Button('关闭').width('100%').backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => this.detailVisible = false)
        }.width('86%').padding(20).backgroundColor(Color.White).borderRadius(20)
      }.width('100%').height('100%')
    }
  }

  @Builder
  private decisionDialog() {
    if (this.decisionVisible && this.selected !== null) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000').onClick(() => this.decisionVisible = false)
        Column({ space: 12 }) {
          Text('驳回调课申请').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').width('100%')
          Text(`${this.selected.courseName ?? this.selected.courseId} · ${this.selected.teacherName ?? this.selected.teacherId}`).fontSize(14).fontColor('#516B80').width('100%')
          TextInput({ placeholder: '驳回意见（必填）', text: this.decisionComment }).height(90).backgroundColor('#F1F6F8').borderRadius(10).onChange((value: string) => this.decisionComment = value)
          Row({ space: 10 }) { Button('取消').layoutWeight(1).onClick(() => this.decisionVisible = false); Button('确认驳回').layoutWeight(1).backgroundColor('#B04A4A').fontColor(Color.White).onClick(() => { void this.submitDecision(); }) }
        }.width('86%').padding(20).backgroundColor(Color.White).borderRadius(20)
      }.width('100%').height('100%')
    }
  }

  build() {
    Stack() { Column() { Row() { Text('‹').fontSize(32).fontColor('#176B87').width(42).onClick(() => this.page = 0); Text('调课申请').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1); Text(`${this.items.length} 条`).fontSize(13).fontColor('#718096') }.width('100%').padding({ left: 18, right: 20, top: 18, bottom: 10 }); Row() { if (this.canSubmit()) { Button('新建申请').backgroundColor('#176B87').fontColor(Color.White).onClick(() => this.openCreate()); } Button('刷新').backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => { void this.load(); }) }.width('100%').justifyContent(FlexAlign.End).padding({ left: 20, right: 20, bottom: 10 }); if (this.loading) { LoadingProgress().color('#176B87').layoutWeight(1) } else { List() { ForEach(this.items, (item: ScheduleChangeListItem) => { ListItem() { this.row(item) } }, (item: ScheduleChangeListItem) => `${item.id}`) }.width('100%').layoutWeight(1).padding({ left: 20, right: 20 }) } }.width('100%').height('100%').backgroundColor('#EDF5F7'); this.formDialog(); this.detailDialog(); this.decisionDialog() }.width('100%').height('100%')
  }
}
