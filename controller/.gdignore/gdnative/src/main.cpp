#include "main.h"



using namespace godot;



void Gdnative::_register_methods() {
    register_method("attempt_connect", &Gdnative::attempt_connect);

    register_property<Gdnative, bool>("connecting", &Gdnative::connecting, false);

    register_signal<Gdnative>((char *)"connected");
    register_signal<Gdnative>((char *)"connection_lost");
}



Gdnative::Gdnative() {
}

Gdnative::~Gdnative() {
}



void Gdnative::_init() {
    connecting = false;
}


void Gdnative::attempt_connect() {
    // Called from Godot when attempt connect button is pressed.
    connecting = true;
}

void Gdnative::attempt_connect_timeout() {
    // Called from Godot when attempt connect times out.
    connecting = false;
}

void Gdnative::disconnect() {
    // Called from Godot when the connection attempt succeeds.
}


void Gdnative::connected() {
    // Called from Gdnative when the connection attempt succeeds.
    connecting = false;
    emit_signal("connected");
}

void Gdnative::connection_lost() {
    // Called from Gdnative when the connection is lost.
    connecting = false;
    emit_signal("connection_lost");
}
