use flutter_rust_bridge::*;

pub fn get_version() -> String {
    "BeamX Core v0.1.0".to_string()
}

pub fn ping_device(device_id: String) -> String {
    format!("Pong from device: {}", device_id)
}
