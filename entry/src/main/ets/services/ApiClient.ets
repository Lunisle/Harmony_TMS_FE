import { http } from '@kit.NetworkKit';
import { ApiConfig } from '../config/ApiConfig';
import {
  ApiEnvelope,
  LoginData,
  LoginRequest,
  RegisterData,
  RegisterRequest,
  UserInfo,
  CurrentUserData,
  StudentListItem,
  StudentDetail,
  StudentPage,
  StudentOptions,
  StudentOptionMajor,
  StudentOptionClassGroup,
  DepartmentInfo,
  StudentMutationRequest,
  TeacherListItem,
  TeacherPage,
  TeacherOptions,
  TeacherMutationRequest,
  DeleteResult,
  ClassroomPage,
  ClassroomOptions,
  ClassroomListItem,
  ClassroomMutationRequest,
  CourseDetail,
  CourseSummary,
  CourseOption,
  SemesterOption,
  ClassroomRequestPage,
  ClassroomRequestListItem,
  ClassroomRequestMutationRequest
  , ClassroomRequestUpdateRequest
  , ClassroomRequestStatusMutation,
  ScheduleChangeListItem,
  ScheduleChangeMutationRequest
  , ScheduleChangePage,
  ExamListItem,
  ExamMutationRequest,
  ExamPage
} from '../models/ApiModels';

interface JsonHeaders {
  'Content-Type': string;
}

interface AuthorizedHeaders extends JsonHeaders {
  'Authorization': string;
}

interface StudentListResponse {
  list: StudentListItem[];
  total: number;
  page: number;
  pageSize: number;
}

interface TeacherListResponse {
  list: TeacherListItem[];
  total: number;
  page: number;
  pageSize: number;
}

interface ClassroomListResponse {
  list: ClassroomListItem[];
  total: number;
  page: number;
  pageSize: number;
}

interface ClassroomRequestListResponse {
  list: ClassroomRequestListItem[];
  total: number;
  page: number;
  pageSize: number;
}

interface ScheduleChangeListResponse {
  list: ScheduleChangeListItem[];
  total: number;
  page: number;
  pageSize: number;
}

interface ExamListResponse {
  list: ExamListItem[];
  total: number;
  page: number;
  pageSize: number;
}

export class ApiClient {
  private static token: string = '';

  static setToken(token: string): void {
    ApiClient.token = token;
  }

  static clearToken(): void {
    ApiClient.token = '';
  }

  static async login(data: LoginRequest): Promise<LoginData> {
    const raw = await ApiClient.request<LoginData>(
      '/auth/login',
      http.RequestMethod.POST,
      data,
      false
    );
    const result: LoginData = { token: raw.token, user: ApiClient.normalizeUser(raw.user) };
    ApiClient.setToken(result.token);
    return result;
  }

  static async register(data: RegisterRequest): Promise<RegisterData> {
    return ApiClient.request<RegisterData>(
      '/auth/register',
      http.RequestMethod.POST,
      data,
      false
    );
  }

  static async getCurrentUser(): Promise<UserInfo> {
    const data = await ApiClient.request<CurrentUserData>(
      '/auth/me',
      http.RequestMethod.GET,
      undefined,
      true
    );
    return {
      id: data.user.id,
      username: data.user.username,
      name: data.user.name,
      displayName: data.user.displayName ?? data.user.name,
      role: data.identity.roleCode.toUpperCase(),
      roleLabel: data.identity.roleLabel,
      isAdministrator: data.identity.isAdministrator,
      student: data.studentProfile,
      teacher: data.teacherProfile,
      studentId: data.studentProfile?.id ?? null,
      teacherId: data.teacherProfile?.id ?? null,
      enabled: data.user.enabled
    };
  }

  static async getStudents(page: number = 1, pageSize: number = 20, keyword: string = '', status: string = '', enabled?: boolean, grade?: number, departmentId?: number, majorId?: number, classGroupId?: number, activated?: boolean): Promise<StudentPage> {
    const params: string[] = [`page=${page}`, `pageSize=${pageSize}`];
    if (keyword.length > 0) params.push(`keyword=${encodeURIComponent(keyword)}`);
    if (status.length > 0) params.push(`status=${status}`);
    if (grade !== undefined) params.push(`grade=${grade}`);
    if (departmentId !== undefined) params.push(`departmentId=${departmentId}`);
    if (majorId !== undefined) params.push(`majorId=${majorId}`);
    if (classGroupId !== undefined) params.push(`classGroupId=${classGroupId}`);
    if (activated !== undefined) params.push(`activated=${activated}`);
    if (enabled !== undefined) params.push(`enabled=${enabled}`);
    const result = await ApiClient.request<StudentListResponse>(
      `/students?${params.join('&')}`,
      http.RequestMethod.GET,
      undefined,
      true
    );
    return {
      items: result.list,
      total: result.total,
      page: result.page,
      pageSize: result.pageSize,
      totalPages: Math.ceil(result.total / result.pageSize)
    };
  }

  static async getStudent(id: number): Promise<StudentDetail> {
    return ApiClient.request<StudentDetail>(
      `/students/${id}`,
      http.RequestMethod.GET,
      undefined,
      true
    );
  }

  static async getStudentOptions(): Promise<StudentOptions> {
    return ApiClient.request<StudentOptions>('/students/options', http.RequestMethod.GET, undefined, true);
  }

  static async createStudent(data: StudentMutationRequest): Promise<StudentDetail> {
    return ApiClient.request<StudentDetail>('/students', http.RequestMethod.POST, data, true);
  }

  static async updateStudent(id: number, data: StudentMutationRequest): Promise<StudentDetail> {
    return ApiClient.request<StudentDetail>(`/students/${id}`, 'PATCH' as http.RequestMethod, data, true);
  }

  static async deleteStudent(id: number): Promise<DeleteResult> {
    return ApiClient.request<DeleteResult>(`/students/${id}`, http.RequestMethod.DELETE, undefined, true);
  }

  static async getTeachers(page: number = 1, pageSize: number = 20, keyword: string = '', departmentId?: number, teacherType: string = '', title: string = ''): Promise<TeacherPage> {
    const params: string[] = [`page=${page}`, `pageSize=${pageSize}`];
    if (keyword.length > 0) params.push(`keyword=${encodeURIComponent(keyword)}`);
    if (departmentId !== undefined) params.push(`departmentId=${departmentId}`);
    if (teacherType.length > 0) params.push(`teacherType=${encodeURIComponent(teacherType)}`);
    if (title.length > 0) params.push(`title=${encodeURIComponent(title)}`);
    const result = await ApiClient.request<TeacherListResponse>(
      `/teachers?${params.join('&')}`,
      http.RequestMethod.GET,
      undefined,
      true
    );
    return {
      items: result.list,
      total: result.total,
      page: result.page,
      pageSize: result.pageSize,
      totalPages: Math.max(1, Math.ceil(result.total / result.pageSize))
    };
  }

  static async getTeacher(id: number): Promise<TeacherListItem> {
    return ApiClient.request<TeacherListItem>(`/teachers/${id}`, http.RequestMethod.GET, undefined, true);
  }

  static async getTeacherOptions(): Promise<TeacherOptions> {
    return ApiClient.request<TeacherOptions>('/teachers/options', http.RequestMethod.GET, undefined, true);
  }

  static async createTeacher(data: TeacherMutationRequest): Promise<TeacherListItem> {
    return ApiClient.request<TeacherListItem>('/teachers', http.RequestMethod.POST, data, true);
  }

  static async updateTeacher(id: number, data: TeacherMutationRequest): Promise<TeacherListItem> {
    return ApiClient.request<TeacherListItem>(`/teachers/${id}`, 'PATCH' as http.RequestMethod, data, true);
  }

  static async deleteTeacher(id: number): Promise<DeleteResult> {
    return ApiClient.request<DeleteResult>(`/teachers/${id}`, http.RequestMethod.DELETE, undefined, true);
  }

  static async getClassrooms(page: number = 1, pageSize: number = 10, keyword: string = '', campus: string = '', building: string = '', type: string = '', status: string = ''): Promise<ClassroomPage> {
    const params: string[] = [`page=${page}`, `pageSize=${pageSize}`];
    if (keyword.trim().length > 0) params.push(`keyword=${encodeURIComponent(keyword.trim())}`);
    if (campus.length > 0) params.push(`campus=${encodeURIComponent(campus)}`);
    if (building.length > 0) params.push(`building=${encodeURIComponent(building)}`);
    if (type.length > 0) params.push(`type=${encodeURIComponent(type)}`);
    if (status.length > 0) params.push(`status=${encodeURIComponent(status)}`);
    const result = await ApiClient.request<ClassroomListResponse>(`/classrooms?${params.join('&')}`, http.RequestMethod.GET, undefined, true);
    return {
      items: result.list ?? [], total: result.total ?? 0, page: result.page ?? page,
      pageSize: result.pageSize ?? pageSize,
      totalPages: Math.max(1, Math.ceil((result.total ?? 0) / (result.pageSize ?? pageSize)))
    };
  }

  static async getClassroom(id: number): Promise<ClassroomListItem> {
    return ApiClient.request<ClassroomListItem>(`/classrooms/${id}`, http.RequestMethod.GET, undefined, true);
  }

  static async getClassroomOptions(): Promise<ClassroomOptions> {
    return ApiClient.request<ClassroomOptions>('/classrooms/options', http.RequestMethod.GET, undefined, true);
  }

  static async createClassroom(data: ClassroomMutationRequest): Promise<ClassroomListItem> {
    return ApiClient.request<ClassroomListItem>('/classrooms', http.RequestMethod.POST, data, true);
  }

  static async updateClassroom(id: number, data: ClassroomMutationRequest): Promise<ClassroomListItem> {
    return ApiClient.request<ClassroomListItem>(`/classrooms/${id}`, 'PATCH' as http.RequestMethod, data, true);
  }

  static async deleteClassroom(id: number): Promise<DeleteResult> {
    return ApiClient.request<DeleteResult>(`/classrooms/${id}`, http.RequestMethod.DELETE, undefined, true);
  }

  static async getCourseDetail(id: number, semesterId?: number): Promise<CourseDetail> {
    const query = semesterId === undefined ? '' : `?semesterId=${semesterId}`;
    return ApiClient.request<CourseDetail>(`/base-data/courses/${id}${query}`, http.RequestMethod.GET, undefined, true);
  }

  static async getCourses(keyword: string = '', departmentId?: number): Promise<CourseSummary[]> {
    const options = await ApiClient.getCourseOptions(keyword, departmentId);
    return options.map((item: CourseOption): CourseSummary => ({
      id: item.id, code: item.code, name: item.name, credits: 0
    }));
  }

  static async getCourseOptions(keyword: string = '', departmentId?: number): Promise<CourseOption[]> {
    const params: string[] = [];
    if (departmentId !== undefined && departmentId > 0) params.push(`departmentId=${departmentId}`);
    if (keyword.trim().length > 0) params.push(`keyword=${encodeURIComponent(keyword.trim())}`);
    const query = params.length > 0 ? `?${params.join('&')}` : '';
    return ApiClient.request<CourseOption[]>(`/base-data/courses/options${query}`, http.RequestMethod.GET, undefined, true);
  }

  static async getSemesterOptions(): Promise<SemesterOption[]> {
    return ApiClient.request<SemesterOption[]>('/base-data/semesters/options', http.RequestMethod.GET, undefined, true);
  }

  static async getDepartments(keyword: string = ''): Promise<DepartmentInfo[]> {
    const query = keyword.trim().length > 0 ? `?keyword=${encodeURIComponent(keyword.trim())}` : '';
    return ApiClient.request<DepartmentInfo[]>(`/base-data/departments${query}`, http.RequestMethod.GET, undefined, true);
  }

  static async getMajors(departmentId?: number, keyword: string = ''): Promise<StudentOptionMajor[]> {
    const params: string[] = [];
    if (departmentId !== undefined && departmentId > 0) params.push(`departmentId=${departmentId}`);
    if (keyword.trim().length > 0) params.push(`keyword=${encodeURIComponent(keyword.trim())}`);
    return ApiClient.request<StudentOptionMajor[]>(`/base-data/majors${params.length > 0 ? `?${params.join('&')}` : ''}`, http.RequestMethod.GET, undefined, true);
  }

  static async getClassGroups(departmentId?: number, majorId?: number, grade?: number): Promise<StudentOptionClassGroup[]> {
    const params: string[] = [];
    if (departmentId !== undefined && departmentId > 0) params.push(`departmentId=${departmentId}`);
    if (majorId !== undefined && majorId > 0) params.push(`majorId=${majorId}`);
    if (grade !== undefined && grade > 0) params.push(`grade=${grade}`);
    return ApiClient.request<StudentOptionClassGroup[]>(`/base-data/class-groups${params.length > 0 ? `?${params.join('&')}` : ''}`, http.RequestMethod.GET, undefined, true);
  }

  static async getClassroomRequests(page: number = 1, pageSize: number = 10, status: string = '', applicantId?: number): Promise<ClassroomRequestPage> {
    const params: string[] = [`page=${page}`, `pageSize=${pageSize}`];
    if (status.length > 0) params.push(`status=${encodeURIComponent(status)}`);
    if (applicantId !== undefined && applicantId > 0) params.push(`applicantId=${applicantId}`);
    const result = await ApiClient.request<ClassroomRequestListResponse>(`/classroom-requests?${params.join('&')}`, http.RequestMethod.GET, undefined, true);
    return { items: result.list ?? [], total: result.total ?? 0, page: result.page ?? page, pageSize: result.pageSize ?? pageSize, totalPages: Math.max(1, Math.ceil((result.total ?? 0) / (result.pageSize ?? pageSize))) };
  }

  static async getClassroomRequest(id: number): Promise<ClassroomRequestListItem> {
    return ApiClient.request<ClassroomRequestListItem>(`/classroom-requests/${id}`, http.RequestMethod.GET, undefined, true);
  }

  static async createClassroomRequest(data: ClassroomRequestMutationRequest): Promise<ClassroomRequestListItem> {
    return ApiClient.request<ClassroomRequestListItem>('/classroom-requests', http.RequestMethod.POST, data, true);
  }

  static async updateClassroomRequestStatus(id: number, status: string, comment?: string): Promise<ClassroomRequestListItem> {
    const data: ClassroomRequestStatusMutation = { status, comment };
    return ApiClient.request<ClassroomRequestListItem>(`/classroom-requests/${id}/status`, 'PATCH' as http.RequestMethod, data, true);
  }

  static async deleteClassroomRequest(id: number): Promise<DeleteResult> {
    return ApiClient.request<DeleteResult>(`/classroom-requests/${id}`, http.RequestMethod.DELETE, undefined, true);
  }

  static async updateClassroomRequest(id: number, data: ClassroomRequestUpdateRequest): Promise<ClassroomRequestListItem> {
    return ApiClient.request<ClassroomRequestListItem>(`/classroom-requests/${id}`, 'PATCH' as http.RequestMethod, data, true);
  }

  static async getScheduleChanges(page: number = 1, pageSize: number = 10, status: string = '', teacherId?: number): Promise<ScheduleChangePage> {
    const query = `page=${page}&pageSize=${pageSize}${status.length > 0 ? `&status=${encodeURIComponent(status)}` : ''}${teacherId !== undefined && teacherId > 0 ? `&teacherId=${teacherId}` : ''}`;
    const result = await ApiClient.request<ScheduleChangeListResponse>(`/schedule-changes?${query}`, http.RequestMethod.GET, undefined, true);
    return { items: result.list ?? [], total: result.total ?? 0, page: result.page ?? page, pageSize: result.pageSize ?? pageSize, totalPages: Math.max(1, Math.ceil((result.total ?? 0) / (result.pageSize ?? pageSize))) };
  }

  static async createScheduleChange(data: ScheduleChangeMutationRequest): Promise<ScheduleChangeListItem> {
    return ApiClient.request<ScheduleChangeListItem>('/schedule-changes', http.RequestMethod.POST, data, true);
  }

  static async getScheduleChange(id: number): Promise<ScheduleChangeListItem> {
    return ApiClient.request<ScheduleChangeListItem>(`/schedule-changes/${id}`, http.RequestMethod.GET, undefined, true);
  }

  static async updateScheduleChangeStatus(id: number, status: string, comment?: string): Promise<ScheduleChangeListItem> {
    const data: ClassroomRequestStatusMutation = { status, comment };
    return ApiClient.request<ScheduleChangeListItem>(`/schedule-changes/${id}/status`, 'PATCH' as http.RequestMethod, data, true);
  }

  static async updateScheduleChange(id: number, data: ScheduleChangeMutationRequest): Promise<ScheduleChangeListItem> {
    return ApiClient.request<ScheduleChangeListItem>(`/schedule-changes/${id}`, 'PATCH' as http.RequestMethod, data, true);
  }

  static async deleteScheduleChange(id: number): Promise<DeleteResult> {
    return ApiClient.request<DeleteResult>(`/schedule-changes/${id}`, http.RequestMethod.DELETE, undefined, true);
  }

  static async getExams(page: number = 1, pageSize: number = 10, keyword: string = '', semesterId?: number, classGroupId?: number): Promise<ExamPage> {
    const params: string[] = [`page=${page}`, `pageSize=${pageSize}`];
    if (keyword.trim().length > 0) params.push(`keyword=${encodeURIComponent(keyword.trim())}`);
    if (semesterId !== undefined && semesterId > 0) params.push(`semesterId=${semesterId}`);
    if (classGroupId !== undefined && classGroupId > 0) params.push(`classGroupId=${classGroupId}`);
    const query = params.join('&');
    const result = await ApiClient.request<ExamListResponse>(`/exams?${query}`, http.RequestMethod.GET, undefined, true);
    return { items: result.list ?? [], total: result.total ?? 0, page: result.page ?? page, pageSize: result.pageSize ?? pageSize, totalPages: Math.max(1, Math.ceil((result.total ?? 0) / (result.pageSize ?? pageSize))) };
  }

  static async getExam(id: number): Promise<ExamListItem> {
    return ApiClient.request<ExamListItem>(`/exams/${id}`, http.RequestMethod.GET, undefined, true);
  }

  static async createExam(data: ExamMutationRequest): Promise<ExamListItem> {
    return ApiClient.request<ExamListItem>('/exams', http.RequestMethod.POST, data, true);
  }

  static async updateExam(id: number, data: ExamMutationRequest): Promise<ExamListItem> {
    return ApiClient.request<ExamListItem>(`/exams/${id}`, 'PATCH' as http.RequestMethod, data, true);
  }

  static async deleteExam(id: number): Promise<DeleteResult> {
    return ApiClient.request<DeleteResult>(`/exams/${id}`, http.RequestMethod.DELETE, undefined, true);
  }

  private static normalizeUser(user: UserInfo): UserInfo {
    return {
      id: user.id,
      username: user.username,
      name: user.name,
      role: user.role.toUpperCase(),
      student: user.student ?? null,
      teacher: user.teacher ?? null,
      enabled: user.enabled ?? true,
      teacherId: user.teacherId,
      studentId: user.studentId,
      departmentId: user.departmentId,
      department: user.department
    };
  }

  private static async request<T>(
    path: string,
    method: http.RequestMethod,
    body: Object | undefined,
    requiresAuth: boolean
  ): Promise<T> {
    const request = http.createHttp();
    const jsonHeaders: JsonHeaders = {
      'Content-Type': 'application/json'
    };
    const authorizedHeaders: AuthorizedHeaders = {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${ApiClient.token}`
    };
    const options: http.HttpRequestOptions = {
      method: method,
      header: requiresAuth ? authorizedHeaders : jsonHeaders,
      connectTimeout: ApiConfig.CONNECT_TIMEOUT,
      readTimeout: ApiConfig.READ_TIMEOUT,
      expectDataType: http.HttpDataType.STRING
    };

    if (body !== undefined) {
      options.extraData = JSON.stringify(body);
    }

    try {
      const response = await request.request(`${ApiConfig.BASE_URL}${path}`, options);
      const raw = typeof response.result === 'string'
        ? response.result
        : JSON.stringify(response.result);
      const envelope = JSON.parse(raw) as ApiEnvelope<T>;

      if (response.responseCode < 200 || response.responseCode >= 300 || !envelope.success) {
        throw new Error(envelope.error?.message ?? `请求失败（${response.responseCode}）`);
      }
      if (envelope.data === undefined) {
        throw new Error('服务器响应中缺少 data');
      }
      return envelope.data;
    } catch (error) {
      if (error instanceof Error) {
        throw error;
      }
      throw new Error('无法连接服务器，请检查后端地址和网络');
    } finally {
      request.destroy();
    }
  }
}
