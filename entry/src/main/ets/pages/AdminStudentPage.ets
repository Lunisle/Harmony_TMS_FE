import { ApiClient } from '../services/ApiClient';
import {
  StudentListItem,
  StudentMutationRequest,
  StudentOptionClassGroup,
  StudentOptionDepartment,
  StudentOptionMajor,
  StudentOptions
} from '../models/ApiModels';

@Component
export struct AdminStudentPage {
  @Link page: number;
  @State students: StudentListItem[] = [];
  @State options: StudentOptions = { departments: [], majors: [], classGroups: [], grades: [], statuses: [] };
  @State loading: boolean = false;
  @State saving: boolean = false;
  @State errorText: string = '';
  @State total: number = 0;
  @State currentPage: number = 1;
  @State totalPages: number = 1;
  @State keyword: string = '';
  @State statusFilter: string = '';
  @State activationFilter: string = '';
  @State gradeFilter: number = 0;
  @State departmentFilter: number = 0;
  @State majorFilter: number = 0;
  @State classFilter: number = 0;
  @State filterVisible: boolean = false;
  @State selectedStudent: StudentListItem | null = null;
  @State formVisible: boolean = false;
  @State deleteVisible: boolean = false;
  @State editingId: number = 0;
  @State formStudentNo: string = '';
  @State formName: string = '';
  @State formClassGroupId: number = 0;
  @State formGrade: number = 0;
  @State parsedGrade: number = 0;
  @State parsedClassCode: string = '';
  @State formStatus: string = 'ENROLLED';
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
      this.options = await ApiClient.getStudentOptions();
      this.options.classGroups = await ApiClient.getClassGroups();
    } catch (_) {
      this.options = {
        departments: [], majors: [], classGroups: [], grades: [],
        statuses: ['ENROLLED', 'SUSPENDED', 'GRADUATED', 'WITHDRAWN']
      };
    }
  }

  private async load(): Promise<void> {
    this.loading = true;
    this.errorText = '';
    try {
      const grade = this.gradeFilter > 0 ? this.gradeFilter : undefined;
      const departmentId = this.departmentFilter > 0 ? this.departmentFilter : undefined;
      const majorId = this.majorFilter > 0 ? this.majorFilter : undefined;
      const classGroupId = this.classFilter > 0 ? this.classFilter : undefined;
      const activated = this.activationFilter === 'ACTIVATED' ? true : this.activationFilter === 'NOT_ACTIVATED' ? false : undefined;
      const result = await ApiClient.getStudents(
        this.currentPage, 20, this.keyword.trim(), this.statusFilter, undefined,
        grade, departmentId, majorId, classGroupId, activated
      );
      this.students = result.items;
      this.total = result.total;
      this.totalPages = Math.max(1, result.totalPages);
    } catch (error) {
      this.errorText = error instanceof Error ? error.message : '加载学生数据失败';
    } finally {
      this.loading = false;
    }
  }

  private statusText(status: string): string {
    if (status === 'ENROLLED') return '在读';
    if (status === 'SUSPENDED') return '休学';
    if (status === 'GRADUATED') return '毕业';
    if (status === 'WITHDRAWN') return '退学';
    return status;
  }

  private activationText(value: string): string {
    if (value === 'ACTIVATED') return '已激活';
    if (value === 'NOT_ACTIVATED') return '未激活';
    return '全部账号';
  }

  private cycleText(current: string, values: string[]): string {
    if (values.length === 0) return '';
    if (current.length === 0) return values[0];
    const index = values.indexOf(current);
    return index < 0 || index >= values.length - 1 ? '' : values[index + 1];
  }

  private cycleRequiredText(current: string, values: string[]): string {
    if (values.length === 0) return current;
    const index = values.indexOf(current);
    return index < 0 || index >= values.length - 1 ? values[0] : values[index + 1];
  }

  private statusSelectIndex(): number {
    if (this.statusFilter === 'ENROLLED') return 1;
    if (this.statusFilter === 'SUSPENDED') return 2;
    if (this.statusFilter === 'GRADUATED') return 3;
    if (this.statusFilter === 'WITHDRAWN') return 4;
    return 0;
  }

  private activationSelectIndex(): number {
    if (this.activationFilter === 'ACTIVATED') return 1;
    if (this.activationFilter === 'NOT_ACTIVATED') return 2;
    return 0;
  }

  private cycleNumber(current: number, values: number[]): number {
    if (values.length === 0) return 0;
    if (current === 0) return values[0];
    const index = values.indexOf(current);
    return index < 0 || index >= values.length - 1 ? 0 : values[index + 1];
  }

  private departmentName(id: number): string {
    if (id === 0) return '全部院系';
    const item = this.options.departments.find((option: StudentOptionDepartment) => option.id === id);
    return item ? item.name : `院系 ${id}`;
  }

  private majorName(id: number): string {
    if (id === 0) return '全部专业';
    const item = this.options.majors.find((option: StudentOptionMajor) => option.id === id);
    return item ? item.name : `专业 ${id}`;
  }

  private classGroupName(id: number): string {
    if (id === 0) return '全部班级';
    const item = this.options.classGroups.find((option: StudentOptionClassGroup) => option.id === id);
    return item ? `${item.code ? `${item.code} · ` : ''}${item.name}` : `班级 ${id}`;
  }

  private availableMajorIds(): number[] {
    return this.options.majors
      .filter((option: StudentOptionMajor) => this.departmentFilter === 0 || option.departmentId === this.departmentFilter)
      .map((option: StudentOptionMajor) => option.id);
  }

  private availableClassIds(): number[] {
    return this.options.classGroups
      .filter((option: StudentOptionClassGroup) => {
        const departmentMatched = this.departmentFilter === 0 || option.departmentId === this.departmentFilter;
        const majorMatched = this.majorFilter === 0 || option.majorId === this.majorFilter;
        const gradeMatched = this.gradeFilter === 0 || option.grade === this.gradeFilter;
        return departmentMatched && majorMatched && gradeMatched;
      })
      .map((option: StudentOptionClassGroup) => option.id);
  }

  private selectNextDepartment(): void {
    const ids = this.options.departments.map((option: StudentOptionDepartment) => option.id);
    this.departmentFilter = this.cycleNumber(this.departmentFilter, ids);
    this.majorFilter = 0;
    this.classFilter = 0;
  }

  private selectNextMajor(): void {
    this.majorFilter = this.cycleNumber(this.majorFilter, this.availableMajorIds());
    this.classFilter = 0;
  }

  private selectNextGrade(): void {
    this.gradeFilter = this.cycleNumber(this.gradeFilter, this.options.grades);
    this.classFilter = 0;
  }

  private applyFilter(): void {
    this.currentPage = 1;
    this.filterVisible = false;
    void this.load();
  }

  private clearFilters(): void {
    this.statusFilter = '';
    this.activationFilter = '';
    this.gradeFilter = 0;
    this.departmentFilter = 0;
    this.majorFilter = 0;
    this.classFilter = 0;
  }

  private async openDetail(item: StudentListItem): Promise<void> {
    try {
      this.selectedStudent = await ApiClient.getStudent(item.id);
    } catch (_) {
      this.selectedStudent = item;
      this.showToast('详情接口暂时不可用，已显示列表数据');
    }
  }

  private openCreate(): void {
    this.editingId = 0;
    this.formStudentNo = '';
    this.formName = '';
    this.formClassGroupId = 0;
    this.formGrade = this.options.grades.length > 0 ? this.options.grades[0] : new Date().getFullYear();
    this.parsedGrade = 0;
    this.parsedClassCode = '';
    this.formStatus = 'ENROLLED';
    this.formPhone = '';
    this.formVisible = true;
  }

  private openEdit(): void {
    if (this.selectedStudent === null) return;
    this.editingId = this.selectedStudent.id;
    this.formStudentNo = this.selectedStudent.studentNo;
    this.formName = this.selectedStudent.name;
    this.formClassGroupId = this.selectedStudent.classGroupId ?? 0;
    this.formGrade = this.selectedStudent.grade ?? 0;
    this.parsedGrade = 0;
    this.parsedClassCode = '';
    this.formStatus = this.selectedStudent.status;
    this.formPhone = this.selectedStudent.phone ?? '';
    this.selectedStudent = null;
    this.formVisible = true;
  }

  private cycleFormClass(): void {
    const ids = this.options.classGroups
      .filter((option: StudentOptionClassGroup) => this.formGrade <= 0 || option.grade === this.formGrade)
      .map((option: StudentOptionClassGroup) => option.id);
    this.formClassGroupId = this.cycleNumber(this.formClassGroupId, ids);
    const selected = this.options.classGroups.find((option: StudentOptionClassGroup) => option.id === this.formClassGroupId);
    if (selected) this.formGrade = selected.grade;
  }

  private cycleFormGrade(): void {
    this.formGrade = this.cycleNumber(this.formGrade, this.options.grades);
    this.formClassGroupId = 0;
  }

  private formClassGroups(): StudentOptionClassGroup[] {
    return this.options.classGroups.filter((option: StudentOptionClassGroup) => this.formGrade <= 0 || option.grade === this.formGrade);
  }

  private formGradeIndex(): number {
    const index = this.options.grades.indexOf(this.formGrade);
    return index >= 0 ? index : 0;
  }

  private formClassIndex(): number {
    const index = this.formClassGroups().findIndex((option: StudentOptionClassGroup) => option.id === this.formClassGroupId);
    return index >= 0 ? index : 0;
  }

  private formStatusIndex(): number {
    if (this.formStatus === 'SUSPENDED') return 1;
    if (this.formStatus === 'GRADUATED') return 2;
    if (this.formStatus === 'WITHDRAWN') return 3;
    return 0;
  }

  private gradeSelectOptions(): SelectOption[] {
    const result: SelectOption[] = [];
    this.options.grades.forEach((grade: number) => {
      const option: SelectOption = { value: `${grade}` };
      result.push(option);
    });
    return result;
  }

  private classSelectOptions(): SelectOption[] {
    const result: SelectOption[] = [];
    this.formClassGroups().forEach((group: StudentOptionClassGroup) => {
      const option: SelectOption = { value: `${group.code ?? ''} · ${group.name}` };
      result.push(option);
    });
    return result;
  }

  private validStudentNo(studentNo: string): boolean {
    return /^[0-9]{12}$/.test(studentNo);
  }

  private parseStudentNo(value: string): void {
    this.formStudentNo = value;
    this.parsedGrade = 0;
    this.parsedClassCode = '';
    if (!this.validStudentNo(value)) return;
    this.parsedGrade = Number(value.substring(0, 4));
    this.parsedClassCode = value.substring(8, 10);
    this.formGrade = this.parsedGrade;
    const matched = this.options.classGroups.find((option: StudentOptionClassGroup) => option.grade === this.parsedGrade && option.code === this.parsedClassCode);
    if (matched) this.formClassGroupId = matched.id;
  }

  private validPhone(phone: string): boolean {
    return phone.length === 0 || /^1[3-9]\d{9}$/.test(phone);
  }

  private async saveStudent(): Promise<void> {
    const studentNo = this.formStudentNo.trim();
    const name = this.formName.trim();
    const phone = this.formPhone.trim();
    if (!this.validStudentNo(studentNo)) {
      this.showToast('学号必须为 12 位数字');
      return;
    }
    if (!name) {
      this.showToast('请填写学生姓名');
      return;
    }
    if (this.formClassGroupId <= 0 || this.formGrade <= 0) {
      this.showToast('请选择学生班级和年级');
      return;
    }
    if (this.parsedGrade > 0 && this.formGrade !== this.parsedGrade) {
      this.showToast('年级与学号解析结果不一致');
      return;
    }
    if (this.parsedClassCode.length > 0) {
      const selectedGroup = this.options.classGroups.find((option: StudentOptionClassGroup) => option.id === this.formClassGroupId);
      if (!selectedGroup || selectedGroup.code !== this.parsedClassCode || selectedGroup.grade !== this.parsedGrade) {
        this.showToast('班级与学号解析结果不一致');
        return;
      }
    }
    if (!this.validPhone(phone)) {
      this.showToast('请输入正确的 11 位手机号');
      return;
    }
    const data: StudentMutationRequest = {
      studentNo: studentNo,
      name: name,
      classGroupId: this.formClassGroupId,
      grade: this.formGrade,
      status: this.formStatus,
      phone: phone.length > 0 ? phone : null
    };
    this.saving = true;
    try {
      if (this.editingId > 0) {
        await ApiClient.updateStudent(this.editingId, data);
        this.showToast('学生信息已更新');
      } else {
        await ApiClient.createStudent(data);
        this.showToast('学生已新增');
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

  private async deleteStudent(): Promise<void> {
    if (this.selectedStudent === null) return;
    this.saving = true;
    try {
      await ApiClient.deleteStudent(this.selectedStudent.id);
      this.deleteVisible = false;
      this.selectedStudent = null;
      this.showToast('学生已删除');
      if (this.students.length === 1 && this.currentPage > 1) this.currentPage--;
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
    if (message.includes('Student number already exists')) return '该学号已存在';
    if (message.includes('Student is referenced')) return '该学生已被业务数据引用，不能删除';
    if (message.includes('Class group not found')) return '所选班级不存在，请刷新后重试';
    return message;
  }

  private showToast(message: string): void {
    try { this.getUIContext().getPromptAction().showToast({ message, duration: 2300 }); } catch (_) {}
  }

  @Builder
  private requiredLabel(label: string) {
    Row({ space: 3 }) {
      Text('*').fontSize(15).fontColor('#D94B4B').fontWeight(FontWeight.Bold)
      Text(label).fontSize(13).fontColor('#516B80')
    }.width('100%').justifyContent(FlexAlign.Start)
  }

  @Builder
  private optionalLabel(label: string) {
    Text(label).fontSize(13).fontColor('#718096').width('100%').textAlign(TextAlign.Start)
  }

  @Builder
  private studentRow(item: StudentListItem) {
    Row() {
      Column({ space: 3 }) {
        Text(item.name).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#17324D').width('100%')
        Text(item.studentNo).fontSize(12).fontColor('#718096').width('100%')
      }.layoutWeight(1).alignItems(HorizontalAlign.Start)
      Text(this.statusText(item.status)).fontSize(13).fontColor('#516B80').width(55).textAlign(TextAlign.Center)
      Text(item.activated === false ? '未激活' : '已激活').fontSize(12)
        .fontColor(item.activated === false ? '#9A6B2F' : '#176B87').width(62).textAlign(TextAlign.Center)
      Text('详情').fontSize(13).fontColor('#176B87').width(48).textAlign(TextAlign.Center)
        .onClick(() => { void this.openDetail(item); })
    }.width('100%').padding({ top: 12, bottom: 12, left: 8, right: 8 }).border({ width: { bottom: 1 }, color: '#E8EFF2' })
  }

  @Builder
  private detailDialog() {
    if (this.selectedStudent !== null && !this.deleteVisible) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#661D3445').onClick(() => this.selectedStudent = null)
        Column({ space: 12 }) {
          Row() {
            Text('学生详情').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
            Text(this.statusText(this.selectedStudent.status)).fontSize(12).fontColor('#176B87').backgroundColor('#E4F2F5')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(10)
            Text(this.selectedStudent.activated === false ? '未激活' : '已激活').fontSize(12)
              .fontColor(this.selectedStudent.activated === false ? '#9A6B2F' : '#176B87').backgroundColor('#E4F2F5')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(10).margin({ left: 6 })
            Text('×').fontSize(26).fontColor('#718096').margin({ left: 8 }).onClick(() => this.selectedStudent = null)
          }
          Row() { Text('姓名').width(72).fontColor('#718096'); Text(this.selectedStudent.name || '暂无数据').fontColor('#17324D').layoutWeight(1) }
          Row() { Text('学号').width(72).fontColor('#718096'); Text(this.selectedStudent.studentNo || '暂无数据').fontColor('#17324D').layoutWeight(1) }
          Row() { Text('学院').width(72).fontColor('#718096'); Text(this.selectedStudent.departmentName ?? '暂无数据').fontColor('#17324D').layoutWeight(1) }
          Row() { Text('专业').width(72).fontColor('#718096'); Text(this.selectedStudent.majorName ?? '暂无数据').fontColor('#17324D').layoutWeight(1) }
          Row() { Text('班级').width(72).fontColor('#718096'); Text(this.selectedStudent.classGroupName ?? this.selectedStudent.classGroup?.name ?? '暂无数据').fontColor('#17324D').layoutWeight(1) }
          Row() { Text('年级').width(72).fontColor('#718096'); Text(this.selectedStudent.grade ? `${this.selectedStudent.grade}` : '暂无数据').fontColor('#17324D').layoutWeight(1) }
          Row() { Text('电话').width(72).fontColor('#718096'); Text(this.selectedStudent.phone ?? '暂无数据').fontColor('#17324D').layoutWeight(1) }
          Text('账号启停与密码重置由“用户与角色”模块维护').fontSize(12).fontColor('#8999A4').width('100%')
          Row({ space: 10 }) {
            Button('编辑资料').layoutWeight(1).backgroundColor('#197C93').fontColor(Color.White).onClick(() => this.openEdit())
            Button('删除学生').layoutWeight(1).backgroundColor('#F7E5E5').fontColor('#B04A4A').onClick(() => this.deleteVisible = true)
          }
        }.width('88%').padding(20).backgroundColor(Color.White).borderRadius(20)
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
            Text('筛选学生').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
            Text('×').fontSize(26).fontColor('#718096').onClick(() => this.filterVisible = false)
          }
          Text('一级筛选 · 学号结构 4-2-2-2-2').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#31566D').width('100%')
          Row({ space: 8 }) {
            TextInput({ placeholder: '年级', text: this.gradeFilter > 0 ? `${this.gradeFilter}` : '' })
              .width('34%').height(40).fontSize(16).textAlign(TextAlign.Center).backgroundColor('#EAF5F7').borderRadius(9).maxLength(4)
              .onChange((value: string) => { this.gradeFilter = value.length > 0 ? Number(value) : 0; this.classFilter = 0; })
            TextInput({ placeholder: '学院', text: this.departmentFilter > 0 ? `${this.departmentFilter}` : '' })
              .width('18%').height(40).fontSize(14).backgroundColor('#EAF5F7').borderRadius(9).maxLength(2)
              .onChange((value: string) => { this.departmentFilter = value.length > 0 ? Number(value) : 0; this.majorFilter = 0; this.classFilter = 0; })
            TextInput({ placeholder: '专业', text: this.majorFilter > 0 ? `${this.majorFilter}` : '' })
              .width('18%').height(40).fontSize(14).backgroundColor('#EAF5F7').borderRadius(9).maxLength(2)
              .onChange((value: string) => { this.majorFilter = value.length > 0 ? Number(value) : 0; this.classFilter = 0; })
            TextInput({ placeholder: '班级', text: this.classFilter > 0 ? `${this.classFilter}` : '' })
              .width('18%').height(40).fontSize(14).backgroundColor('#EAF5F7').borderRadius(9).maxLength(2)
              .onChange((value: string) => this.classFilter = value.length > 0 ? Number(value) : 0)
          }
          Text('二级筛选').fontSize(14).fontWeight(FontWeight.Bold).fontColor('#516B80').width('100%')
          Row({ space: 8 }) {
            Select([
              { value: '任意' }, { value: '在读' }, { value: '休学' }, { value: '毕业' }, { value: '退学' }
            ]).selected(this.statusSelectIndex()).layoutWeight(1).height(40).backgroundColor('#EAF5F7').fontColor('#31566D')
              .onSelect((index: number) => {
                this.statusFilter = index === 1 ? 'ENROLLED' : index === 2 ? 'SUSPENDED' : index === 3 ? 'GRADUATED' : index === 4 ? 'WITHDRAWN' : '';
              })
            Select([
              { value: '任意' }, { value: '已激活' }, { value: '未激活' }
            ]).selected(this.activationSelectIndex()).layoutWeight(1).height(40).backgroundColor('#EAF5F7').fontColor('#31566D')
              .onSelect((index: number) => {
                this.activationFilter = index === 1 ? 'ACTIVATED' : index === 2 ? 'NOT_ACTIVATED' : '';
              })
            Button('确认筛选').layoutWeight(1).backgroundColor('#197C93').fontColor(Color.White).onClick(() => this.applyFilter())
          }
        }.width('92%').padding(18).backgroundColor('#F7FCFD').borderRadius(20)
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
              Text(this.editingId > 0 ? '编辑学生' : '新增学生').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
              Text('×').fontSize(26).fontColor('#718096').onClick(() => this.formVisible = false)
            }
            this.requiredLabel('学生学号')
            TextInput({ placeholder: '请输入 12 位学生学号', text: this.formStudentNo }).type(InputType.Number).maxLength(12)
              .height(46).backgroundColor('#F1F6F8').borderRadius(10).onChange((value: string) => this.parseStudentNo(value))
            this.requiredLabel('学生姓名')
            TextInput({ placeholder: '请输入学生姓名', text: this.formName }).height(46).backgroundColor('#F1F6F8').borderRadius(10)
              .onChange((value: string) => this.formName = value)
            this.requiredLabel('年级')
            Select(this.gradeSelectOptions()).selected(this.formGradeIndex()).width('100%').height(46)
              .backgroundColor('#EAF5F7').fontColor('#31566D').onSelect((index: number) => { this.formGrade = this.options.grades[index]; this.formClassGroupId = 0; })
            this.requiredLabel('班级')
            Select(this.classSelectOptions()).selected(this.formClassIndex()).width('100%').height(46)
              .backgroundColor('#EAF5F7').fontColor('#31566D').onSelect((index: number) => { const selected = this.formClassGroups()[index]; if (selected) { this.formClassGroupId = selected.id; this.formGrade = selected.grade; } })
            this.requiredLabel('学籍状态')
            Select([{ value: '在读' }, { value: '休学' }, { value: '毕业' }, { value: '退学' }]).selected(this.formStatusIndex()).width('100%').height(46)
              .backgroundColor('#EAF5F7').fontColor('#31566D').onSelect((index: number) => { this.formStatus = index === 1 ? 'SUSPENDED' : index === 2 ? 'GRADUATED' : index === 3 ? 'WITHDRAWN' : 'ENROLLED'; })
            this.optionalLabel('联系电话（可选）')
            TextInput({ placeholder: '请输入联系电话', text: this.formPhone }).type(InputType.PhoneNumber).maxLength(11)
              .height(46).backgroundColor('#F1F6F8').borderRadius(10).onChange((value: string) => this.formPhone = value)
            Button(this.saving ? '保存中…' : '保存').width('100%').height(48).backgroundColor('#197C93').fontColor(Color.White)
              .enabled(!this.saving).onClick(() => { void this.saveStudent(); })
          }.width('100%').padding(20).backgroundColor(Color.White).borderRadius(20)
        }.width('88%').height('80%')
      }.width('100%').height('100%')
    }
  }

  @Builder
  private deleteDialog() {
    if (this.deleteVisible && this.selectedStudent !== null) {
      Stack() {
        Column().width('100%').height('100%').backgroundColor('#66000000')
        Column({ space: 14 }) {
          Text('确认删除学生？').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#17324D').width('100%')
          Text(`将删除 ${this.selectedStudent.name}（${this.selectedStudent.studentNo}）。若学生已有考试或毕业审核记录，系统会拒绝删除。`)
            .fontSize(14).fontColor('#516B80').width('100%')
          Row({ space: 10 }) {
            Button('取消').layoutWeight(1).backgroundColor('#E8EFF2').fontColor('#516B80').onClick(() => this.deleteVisible = false)
            Button(this.saving ? '删除中…' : '确认删除').layoutWeight(1).backgroundColor('#B04A4A').fontColor(Color.White)
              .enabled(!this.saving).onClick(() => { void this.deleteStudent(); })
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
          Text('学生管理').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#17324D').layoutWeight(1)
          Text(`${this.total}人`).fontSize(13).fontColor('#718096')
        }.width('100%').padding({ left: 18, right: 20, top: 18, bottom: 10 })
        Row({ space: 8 }) {
          TextInput({ placeholder: '搜索学号或姓名', text: this.keyword }).layoutWeight(1).height(42).backgroundColor(Color.White).borderRadius(10)
            .onChange((value: string) => this.keyword = value).onSubmit(() => { this.currentPage = 1; void this.load(); })
          Button('新增').height(40).backgroundColor('#176B87').onClick(() => this.openCreate())
          Button('筛选').height(40).backgroundColor('#E4F2F5').fontColor('#176B87').onClick(() => this.filterVisible = true)
        }.width('100%').padding({ left: 20, right: 20, bottom: 8 })
        Row() {
          Text('学生').layoutWeight(1).fontSize(13).fontColor('#516B80')
          Text('学籍').width(55).textAlign(TextAlign.Center).fontSize(13).fontColor('#516B80')
          Text('激活').width(62).textAlign(TextAlign.Center).fontSize(13).fontColor('#516B80')
          Text('详情').width(48).textAlign(TextAlign.Center).fontSize(13).fontColor('#516B80')
        }.width('100%').padding({ left: 28, right: 28, top: 12, bottom: 12 }).backgroundColor('#E4F2F5')
        Text(`当前筛选：${this.statusFilter.length === 0 ? '全部学籍' : this.statusText(this.statusFilter)} · ${this.activationText(this.activationFilter)}`)
          .fontSize(12).fontColor('#8999A4').width('100%').padding({ left: 20, top: 8, bottom: 4 })
        if (this.loading) {
          Column({ space: 12 }) { LoadingProgress().color('#176B87'); Text('正在加载学生数据').fontSize(13).fontColor('#718096') }
            .layoutWeight(1).justifyContent(FlexAlign.Center)
        } else if (this.errorText.length > 0) {
          Column({ space: 12 }) {
            Text(this.errorText).fontSize(14).fontColor('#C04A4A').textAlign(TextAlign.Center)
            Button('重新加载').backgroundColor('#176B87').onClick(() => { void this.load(); })
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
        } else if (this.students.length === 0) {
          Column({ space: 10 }) {
            Text('暂无符合条件的学生').fontSize(16).fontColor('#516B80')
            Text('可调整搜索或筛选条件').fontSize(13).fontColor('#8999A4')
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
        } else {
          List() {
            ForEach(this.students, (item: StudentListItem) => { ListItem() { this.studentRow(item) } }, (item: StudentListItem) => `${item.id}`)
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
