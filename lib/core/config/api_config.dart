/// Dirección del backend. Se puede cambiar al compilar con
/// `--dart-define=API_BASE_URL=http://192.168.0.10:3000`.
const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');
