#![no_std]
#![no_main]
use panic_halt as _;



mod servo;
mod map;



#[arduino_hal::entry]
fn main() -> ! {

    let     dp    = arduino_hal::Peripherals::take().unwrap();
    let     pins  = arduino_hal::pins!(dp);
    let mut adc   = arduino_hal::Adc::new(dp.ADC, Default::default());

    let input = pins.a0.into_analog_input(&mut adc);
    let servo = servo::Servo::new(pins.d9, dp.TC1);

    loop {
        let value = input.analog_read(&mut adc);
        let angle = map::map::<map::U16>(value, 0, 1024, 0, 180);
        servo.write_angle(angle);
        arduino_hal::delay_ms(15);
    }

}
