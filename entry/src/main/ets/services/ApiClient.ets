import { http } from '@kit.NetworkKit';
import { ApiConfig } from '../config/ApiConfig';
import {
  ApiEnvelope,
  LoginData,
  LoginRequest,
  RegisterData,
  RegisterRequest,
  UserInfo,
  StudentListItem,
  StudentDetail,
  StudentPage,
  StudentOptions,
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
  CourseSummary
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
    const user = await ApiClient.request<UserInfo>(
      '/auth/me',
      http.RequestMethod.GET,
      undefined,
      true
    );
    return ApiClient.normalizeUser(user);
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
    const params: string[] = [];
    if (keyword.trim().length > 0) params.push(`keyword=${encodeURIComponent(keyword.trim())}`);
    if (departmentId !== undefined && departmentId > 0) params.push(`departmentId=${departmentId}`);
    const query = params.length > 0 ? `?${params.join('&')}` : '';
    return ApiClient.request<CourseSummary[]>(`/base-data/courses${query}`, http.RequestMethod.GET, undefined, true);
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
