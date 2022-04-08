#ifndef GDNATIVE_H
#define GDNATIVE_H

#include <Godot.hpp>
#include <Node.hpp>



namespace godot {

    class Gdnative : public Node {
        GODOT_CLASS(Gdnative, Node)

    private:
        bool connecting;

    public:
        static void _register_methods();

        Gdnative();
        ~Gdnative();

        void _init();

        void attempt_connect();
    };

}

#endif
