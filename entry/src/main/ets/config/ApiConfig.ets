export class ApiConfig {
  // Team backend (NestJS) LAN address. Replace only the host when the PC's IP changes.
  static readonly BASE_URL: string = 'http://192.168.146.1:3001/api';
  static readonly CONNECT_TIMEOUT: number = 10000;
  static readonly READ_TIMEOUT: number = 10000;
}
