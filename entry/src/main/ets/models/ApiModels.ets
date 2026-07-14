export interface ClassGroupInfo {
  id: number;
  name: string;
  grade: number;
  classNo: string;
}

export interface DepartmentInfo {
  id: number;
  name: string;
  code: string;
  type?: string | null;
}

export interface TeacherInfo {
  id: number;
  employeeNo: string;
  name: string;
}

export interface LinkedUserInfo {
  id: number;
  enabled: boolean;
}

export interface StudentProfile {
  id: number;
  studentNo: string;
  name: string;
  className?: string | null;
  classGroupId: number | null;
  classGroup?: ClassGroupInfo | null;
  grade: number | null;
  status: string;
}

export interface StudentListItem {
  id: number;
  studentNo: string;
  name: string;
  classGroupId: number | null;
  classGroup?: ClassGroupInfo | null;
  grade: number | null;
  status: string;
  phone?: string | null;
  user?: LinkedUserInfo | null;
  activated?: boolean;
  enabled?: boolean;
  departmentId?: number | null;
  departmentName?: string | null;
  majorId?: number | null;
  majorName?: string | null;
}

export interface StudentPage {
  items: StudentListItem[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
}

export interface StudentDetail extends StudentListItem {
  activated: boolean;
  enabled: boolean;
}

export interface UserInfo {
  id: number;
  username: string;
  name?: string;
  role: string;
  teacherId?: number | null;
  studentId?: number | null;
  student: StudentProfile | null;
  enabled?: boolean;
  departmentId?: number;
  department?: DepartmentInfo | null;
  teacher?: TeacherInfo | null;
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginData {
  token: string;
  user: UserInfo;
}

export interface RegisterRequest {
  studentNo: string;
  name: string;
  password: string;
}

export interface RegisterData {
  studentNo: string;
  message: string;
}

export interface ApiErrorData {
  code: string;
  message: string;
}

export interface ApiEnvelope<T> {
  success: boolean;
  data?: T;
  error?: ApiErrorData;
}
