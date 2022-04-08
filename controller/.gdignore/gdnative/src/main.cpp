#include "main.h"



using namespace godot;



void Gdnative::_register_methods() {
    register_method("attempt_connect", &Gdnative::attempt_connect);

    register_property<Gdnative, bool>("connecting", &Gdnative::connecting, false);

    register_signal<Gdnative>((char *)"connected");
    register_signal<Gdnative>((char *)"disconnected");
}



Gdnative::Gdnative() {
}

Gdnative::~Gdnative() {
}



void Gdnative::_init() {
    connecting = false;
}

void Gdnative::attempt_connect() {
    Godot::print(String("Connect"));
}
