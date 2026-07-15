import { ApiClient } from '../services/ApiClient';
import {
  TeacherListItem,
  TeacherMutationRequest,
  TeacherOptionDepartment,
  TeacherOptions
} from '../models/ApiModels';

@Component
export struct AdminTeacherPage {
  @Link page: number;
  @State teachers: TeacherListItem[] = [];
  @State options: TeacherOptions = { departments: [], titles: [], teacherTypes: [] };
  @State loading: boolean = false;
  @State saving: boolean = false;
  @State errorText: string = '';
  @State total: number = 0;
  @State currentPage: number = 1;
  @State totalPages: number = 1;
  @State keyword: string = '';
  @State departmentId: number = 0;
  @State teacherType: string = '';
  @State titleFilter: string = '';
  @State filterVisible: boolean = false;
  @State selectedTeacher: TeacherListItem | null = null;
  @State formVisible: boolean = false;
  @State deleteVisible: boolean = false;
  @State editingId: number = 0;
  @State formEmployeeNo: string = '';
  @State formName: string = '';
  @State formDepartmentId: number = 0;
  @State formTeacherType: string = '';
  @State formTitle: string = '';
  @State formPhone: string = '';

  aboutToAppear(): void {
    void this.initialize();
  }

  private async initialize(): Promise<void> {
    await this.loadOptions();
    await this.load();
  }

  private async loadOptions(): Promise<void> {
    try {
      this.options = await ApiClient.getTeacherOptions();
    } catch (_) {
      this.options = { departments: [], titles: ['教授', '副教授', '讲师'], teacherTypes: ['专任教师', '外聘教师'] };
    }
  }

  private async load(): Promise<void> {
    this.loading = true;
    this.errorText = '';
    try {
      const departmentId = this.departmentId > 0 ? this.departmentId : undefined;
      const result = await ApiClient.getTeachers(this.currentPage, 20, this.keyword.trim(), departmentId, this.teacherType, this.titleFilter);
      this.teachers = result.items;
      this.total = result.total;
      this.totalPages = result.totalPages;
    } catch (error) {
      this.errorText = error instanceof Error ? error.message : '加载教师数据失败';
    } finally {
      this.loading = false;
    }
  }

  private departmentName(id: number): string {
    if (id === 0) return '全部部门';
    const item = this.options.departments.find((department: TeacherOptionDepartment) => department.id === id);
    return item ? item.name : `部门 ${id}`;
  }

  private cycleDepartment(current: number): number {
    if (this.options.departments.length === 0) return 0;
    if (current === 0) return this.options.departments[0].id;
    const index = this.options.departments.findIndex((department: TeacherOptionDepartment) => department.id === current);
    return index < 0 || index >= this.options.departments.length - 1 ? 0 : this.options.departments[index + 1].id;
  }

  private cycleText(current: string, values: string[]): string {
    if (values.length === 0) return '';
    if (current.length === 0) return values[0];
    const index = values.indexOf(current);
    return index < 0 || index >= values.length - 1 ? '' : values[index + 1];
  }

  private departmentSelectIndex(id: number): number {
    const index = this.options.departments.findIndex((department: TeacherOptionDepartment) => department.id === id);
    return index >= 0 ? index + 1 : 0;
  }

  private textSelectIndex(value: string, values: string[]): number {
    const index = values.indexOf(value);
    return index >= 0 ? index + 1 : 0;
  }

  private departmentSelectOptions(placeholder: string): SelectOption[] {
    const result: SelectOption[] = [{ value: placeholder }];
    this.options.departments.forEach((department: TeacherOptionDepartment) => {
      result.push({ value: department.name });
    });
    return result;
  }

  private textSelectOptions(placeholder: string, values: string[]): SelectOption[] {
    const result: SelectOption[] = [{ value: placeholder }];
    values.forEach((value: string) => result.push({ value }));
    return result;
  }

  private applyFilter(): void {
    this.currentPage = 1;
    this.filterVisible = false;
    void this.load();
  }

  private clearFilter(): void {
    this.departmentId = 0;
    this.teacherType = '';
    this.titleFilter = '';
  }

  private async openDetail(item: TeacherListItem): Promise<void> {
    try {
      this.selectedTeacher = await ApiClient.getTeacher(item.id);
    } catch (_) {
      this.selectedTeacher = item;
      this.showToast('详情接口暂时不可用，已显示列表数据');
    }
  }

  private openCreate(): void {
    this.editingId = 0;
    this.formEmployeeNo = '';
    this.formName = '';
    this.formDepartmentId = 0;
    this.formTeacherType = '';
    this.formTitle = '';
    this.formPhone = '';
    this.formVisible = true;
  }

  private openEdit(): void {
    if (this.selectedTeacher === null) return;
    this.editingId = this.selectedTeacher.id;
    this.formEmployeeNo = this.selectedTeacher.employeeNo;
    this.formName = this.selectedTeacher.name;
    this.formDepartmentId = this.selectedTeacher.departmentId ?? 0;
    this.formTeacherType = this.selectedTeacher.teacherType ?? '';
    this.formTitle = this.selectedTeacher.title ?? '';
    this.formPhone = this.selectedTeacher.phone ?? '';
    this.selectedTeacher = null;
    this.formVisible = true;
  }

  private validPhone(phone: string): boolean {
    if (phone.length === 0) return true;
    return /^1[3-9]\d{9}$/.test(phone);
  }

  private async saveTeacher(): Promise<void> {
    if (!this.formEmployeeNo.trim() || !this.formName.trim()) {
      this.showToast('请填写教师工号和姓名');
      return;
    }
    if (!this.validPhone(this.formPhone.trim())) {
      this.showToast('请输入正确的 11 位手机号');
      return;
    }
    const data: TeacherMutationRequest = {
      employeeNo: this.formEmployeeNo.trim(),
      name: this.formName.trim(),
      departmentId: this.formDepartmentId > 0 ? this.formDepartmentId : undefined,
      teacherType: this.formTeacherType.length > 0 ? this.formTeacherType : undefined,
      title: this.formTitle.length > 0 ? this.formTitle : undefined,
      phone: this.formPhone.trim().length > 0 ? this.formPhone.trim() : undefined
    };
    this.saving = true;
    try {
      if (this.editingId > 0) {
        await ApiClient.updateTeacher(this.editingId, data);
        this.showToast('教师信息已更新');
      } else {
        await ApiClient.createTeacher(data);
        this.showToast('教师已新增');
      }
      this.formVisible = false;
      await this.loadOptions();
      await this.load();
    } catch (error) {
      this.showToast(this.readableError(error));
    } finally {
      this.saving = false;
    }
  }

  private async deleteTeacher(): Promise<void> {
    if (this.selectedTeacher === null) return;
    this.saving = true;
    try {
      await ApiClient.deleteTeacher(this.selectedTeacher.id);
      this.deleteVisible = false;
      this.selectedTeacher = null;
      this.showToast('教师已删除');
      await this.load();
    } catch (error) {
      this.deleteVisible = false;
      this.showToast(this.readableError(error));
    } finally {
      this.saving = false;
    }
  }

  private readableError(error: Object): string {
    const message = error instanceof Error ? error.message : '操作失败，请稍后重试';
    if (message.includes('Employee number already exists')) return '教师工号已存在';
    if (message.includes('Teacher is referenced')) return '该教师已被业务数据引用，不能删除';
    if (message.includes('Department not found')) return '所选部门不存在，请刷新后重试';
    return message;
  }

  private showToast(message: string): void {
    try { this.getUIContext().getPromptAction().showToast({ message, duration: 2400 }); } catch (_) {}
  }

  @Builder
  private teacherRow(item: TeacherListItem) {
    Row() {
      Column({ space: 3 }) {
        Text(item.name).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#17324D').width('100%')
        Text(item.employeeNo).fontSize(12).fontColor('#718096').width('100%')
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      Text(item.teacherType ?? '未设置').fontSize(13).fontColor('#516B80').width(72).textAlign(TextAlign.Center)
        .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
      Text(item.title ?? '未设置').fontSize(13).fontColor('#516B80').width(62).textAlign(TextAlign.Center)
        .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
      Text('详情').fontSize(13).fontColor('#176B87').width(48).textAlign(TextAlign.Center)
        .onClick(() => { void this.openDetail(item); })
    }
    .width('100%').padding({ top: 12, bottom: 12, left: 8, right: 8 })
    .border({ width: { bottom: 1 }, color: '#E8EFF2' })
  }

  @Builder
  private detailDialog() {
    if (this.selectedTeacher !== null && !this.deleteVisible) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#661D3445').onClick(() => this.selectedTeacher = null)
        Column({ space: 13 }) {
          Row() {
            Text('教师详情').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
            Text('×').fontSize(26).fontColor('#718096').onClick(() => this.selectedTeacher = null)
          }
          Row() { Text('姓名').width(76).fontColor('#718096'); Text(this.selectedTeacher.name).fontColor('#17324D').layoutWeight(1) }
          Row() { Text('工号').width(76).fontColor('#718096'); Text(this.selectedTeacher.employeeNo).fontColor('#17324D').layoutWeight(1) }
          Row() { Text('部门').width(76).fontColor('#718096'); Text(this.selectedTeacher.departmentName ?? '未设置').fontColor('#17324D').layoutWeight(1) }
          Row() { Text('类型').width(76).fontColor('#718096'); Text(this.selectedTeacher.teacherType ?? '未设置').fontColor('#17324D').layoutWeight(1) }
          Row() { Text('职称').width(76).fontColor('#718096'); Text(this.selectedTeacher.title ?? '未设置').fontColor('#17324D').layoutWeight(1) }
          Row() { Text('电话').width(76).fontColor('#718096'); Text(this.selectedTeacher.phone ?? '未设置').fontColor('#17324D').layoutWeight(1) }
          Row({ space: 10 }) {
            Button('编辑资料').layoutWeight(1).backgroundColor('#197C93').fontColor(Color.White).onClick(() => this.openEdit())
            Button('删除教师').layoutWeight(1).backgroundColor('#F7E5E5').fontColor('#B04A4A').onClick(() => this.deleteVisible = true)
          }
        }.width('86%').padding(20).backgroundColor(Color.White).borderRadius(20)
      }.width('100%').height('100%')
    }
  }

  @Builder
  private filterDialog() {
    if (this.filterVisible) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000').onClick(() => this.filterVisible = false)
        Column({ space: 14 }) {
          Row() {
            Text('筛选教师').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
            Text('×').fontSize(26).fontColor('#718096').onClick(() => this.filterVisible = false)
          }
          Select(this.departmentSelectOptions('任意部门')).selected(this.departmentSelectIndex(this.departmentId)).width('100%').height(44)
            .backgroundColor('#EAF5F7').fontColor('#31566D').onSelect((index: number) => this.departmentId = index > 0 ? this.options.departments[index - 1].id : 0)
          Select(this.textSelectOptions('任意教师类型', this.options.teacherTypes)).selected(this.textSelectIndex(this.teacherType, this.options.teacherTypes)).width('100%').height(44)
            .backgroundColor('#EAF5F7').fontColor('#31566D').onSelect((index: number) => this.teacherType = index > 0 ? this.options.teacherTypes[index - 1] : '')
          Select(this.textSelectOptions('任意职称', this.options.titles)).selected(this.textSelectIndex(this.titleFilter, this.options.titles)).width('100%').height(44)
            .backgroundColor('#EAF5F7').fontColor('#31566D').onSelect((index: number) => this.titleFilter = index > 0 ? this.options.titles[index - 1] : '')
          Row({ space: 10 }) {
            Button('清空').layoutWeight(1).backgroundColor('#E8EFF2').fontColor('#516B80').onClick(() => this.clearFilter())
            Button('应用筛选').layoutWeight(1).backgroundColor('#197C93').fontColor(Color.White).onClick(() => this.applyFilter())
          }
        }.width('88%').padding(20).backgroundColor('#F7FCFD').borderRadius(20)
      }.width('100%').height('100%')
    }
  }

  @Builder
  private formDialog() {
    if (this.formVisible) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000')
        Scroll() {
          Column({ space: 12 }) {
            Row() {
              Text(this.editingId > 0 ? '编辑教师' : '新增教师').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
              Text('×').fontSize(26).fontColor('#718096').onClick(() => this.formVisible = false)
            }
            TextInput({ placeholder: '教师工号（必填）', text: this.formEmployeeNo }).height(46).backgroundColor('#F1F6F8').borderRadius(10)
              .onChange((value: string) => this.formEmployeeNo = value)
            TextInput({ placeholder: '教师姓名（必填）', text: this.formName }).height(46).backgroundColor('#F1F6F8').borderRadius(10)
              .onChange((value: string) => this.formName = value)
            Select(this.departmentSelectOptions('选择所属部门（可选）')).selected(this.departmentSelectIndex(this.formDepartmentId)).width('100%').height(46)
              .backgroundColor('#EAF5F7').fontColor('#31566D').onSelect((index: number) => this.formDepartmentId = index > 0 ? this.options.departments[index - 1].id : 0)
            Select(this.textSelectOptions('选择教师类型（可选）', this.options.teacherTypes)).selected(this.textSelectIndex(this.formTeacherType, this.options.teacherTypes)).width('100%').height(46)
              .backgroundColor('#EAF5F7').fontColor('#31566D').onSelect((index: number) => this.formTeacherType = index > 0 ? this.options.teacherTypes[index - 1] : '')
            Select(this.textSelectOptions('选择职称（可选）', this.options.titles)).selected(this.textSelectIndex(this.formTitle, this.options.titles)).width('100%').height(46)
              .backgroundColor('#EAF5F7').fontColor('#31566D').onSelect((index: number) => this.formTitle = index > 0 ? this.options.titles[index - 1] : '')
            TextInput({ placeholder: '联系电话（可选）', text: this.formPhone }).type(InputType.PhoneNumber).height(46).backgroundColor('#F1F6F8').borderRadius(10)
              .onChange((value: string) => this.formPhone = value)
            Button(this.saving ? '保存中…' : '保存').width('100%').height(48).backgroundColor('#197C93').fontColor(Color.White)
              .enabled(!this.saving).onClick(() => { void this.saveTeacher(); })
          }.width('100%').padding(20).backgroundColor(Color.White).borderRadius(20)
        }.width('88%').height('78%')
      }.width('100%').height('100%')
    }
  }

  @Builder
  private deleteDialog() {
    if (this.deleteVisible && this.selectedTeacher !== null) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000')
        Column({ space: 14 }) {
          Text('确认删除教师？').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').width('100%')
          Text(`将删除 ${this.selectedTeacher.name}（${this.selectedTeacher.employeeNo}）。若教师已关联课程、考试或教学日志，系统会拒绝删除。`)
            .fontSize(14).fontColor('#516B80').width('100%')
          Row({ space: 10 }) {
            Button('取消').layoutWeight(1).backgroundColor('#E8EFF2').fontColor('#516B80').onClick(() => this.deleteVisible = false)
            Button(this.saving ? '删除中…' : '确认删除').layoutWeight(1).backgroundColor('#B04A4A').fontColor(Color.White)
              .enabled(!this.saving).onClick(() => { void this.deleteTeacher(); })
          }
        }.width('84%').padding(20).backgroundColor(Color.White).borderRadius(20)
      }.width('100%').height('100%')
    }
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Text('‹').fontSize(32).fontColor('#176B87').width(42).onClick(() => this.page = 0)
          Text('教师管理').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
          Text(`${this.total}人`).fontSize(13).fontColor('#718096')
        }.width('100%').padding({ left: 18, right: 20, top: 18, bottom: 10 })
        Row({ space: 8 }) {
          TextInput({ placeholder: '搜索工号或姓名', text: this.keyword }).layoutWeight(1).height(42).backgroundColor(Color.White).borderRadius(10)
            .onChange((value: string) => this.keyword = value).onSubmit(() => { this.currentPage = 1; void this.load(); })
          Button('新增').height(40).backgroundColor('#176B87').onClick(() => this.openCreate())
          Button('筛选').height(40).backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => this.filterVisible = true)
        }.width('100%').padding({ left: 20, right: 20, bottom: 8 })
        Row() {
          Text('教师').layoutWeight(1).fontSize(13).fontColor('#516B80')
          Text('类型').width(72).textAlign(TextAlign.Center).fontSize(13).fontColor('#516B80')
          Text('职称').width(62).textAlign(TextAlign.Center).fontSize(13).fontColor('#516B80')
          Text('详情').width(48).textAlign(TextAlign.Center).fontSize(13).fontColor('#516B80')
        }.width('100%').padding({ left: 28, right: 28, top: 12, bottom: 12 }).backgroundColor('#E4F2F5')
        Text(`当前筛选：${this.departmentName(this.departmentId)} · ${this.teacherType || '全部类型'} · ${this.titleFilter || '全部职称'}`)
          .fontSize(12).fontColor('#8999A4').width('100%').padding({ left: 20, right: 20, top: 4, bottom: 8 })
        if (this.loading) {
          Column({ space: 12 }) { LoadingProgress().color('#176B87'); Text('正在加载教师数据').fontSize(13).fontColor('#718096') }
            .layoutWeight(1).justifyContent(FlexAlign.Center)
        } else if (this.errorText.length > 0) {
          Column({ space: 12 }) {
            Text(this.errorText).fontSize(14).fontColor('#C04A4A').textAlign(TextAlign.Center)
            Button('重新加载').backgroundColor('#176B87').onClick(() => { void this.load(); })
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
        } else if (this.teachers.length === 0) {
          Column({ space: 10 }) {
            Text('暂无符合条件的教师').fontSize(16).fontColor('#516B80')
            Text('可调整筛选条件或新增教师').fontSize(13).fontColor('#8999A4')
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.teachers, (item: TeacherListItem) => { ListItem() { this.teacherRow(item) } }, (item: TeacherListItem) => `${item.id}`)
          }.width('100%').layoutWeight(1).padding({ left: 20, right: 20 })
          Row({ space: 12 }) {
            Button('上一页').enabled(this.currentPage > 1 && !this.loading).backgroundColor('#E4F2F5').fontColor('#176B87')
              .onClick(() => { this.currentPage--; void this.load(); })
            Text(`${this.currentPage} / ${this.totalPages}`).fontSize(13).fontColor('#516B80')
            Button('下一页').enabled(this.currentPage < this.totalPages && !this.loading).backgroundColor('#E4F2F5').fontColor('#176B87')
              .onClick(() => { this.currentPage++; void this.load(); })
          }.width('100%').justifyContent(FlexAlign.Center).padding({ top: 8, bottom: 16 })
        }
      }.width('100%').height('100%').backgroundColor('#EDF5F7')
      this.detailDialog()
      this.filterDialog()
      this.formDialog()
      this.deleteDialog()
    }.width('100%').height('100%')
  }
}
