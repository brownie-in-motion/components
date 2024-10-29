import gleam/int

import lustre
import lustre/attribute
import lustre/element/html
import lustre/event

import button.{
    init_rb,
    update_rb,
    view_rb,
    Clicked,
}

import components.{
    init_component,
    update_component,
    update_context,
    update_finally,
    view_component,
    view_context,
}

pub type Model = Int
pub type Msg { Double }

// we use two button components that each have *internal* state and events
// - each button has either red, green, or blue outline
// - this color is updated on hover
//
// these button components also
// - look at *external* state for their contents, and
// - emit an *external* event on click

pub fn init(_flags) {
    use <- init_component(init_rb(Nil))
    use <- init_component(init_rb(Nil))

    0
}

pub fn view(model) {
    // get the first button's view
    use first_button, context <- view_component(view_context(model), view_rb)

    // get the second button's view
    use second_button, context <- view_component(context, view_rb)

    html.div(
        [
            attribute.style([
                #("display", "flex"),
                #("gap", "0.25rem"),
            ])
        ],
        [
            // draw the first button with params
            first_button("+"),

            html.text(int.to_string(context.model)),

            // draw the second button with params
            second_button("-"),

            // draw another button ourselves
            html.button(
                [event.on_click(context.emit(Double))],
                [html.text("double")],
            )
        ],
    )
}

pub fn update(msg, model) {
    // handle first button's external events
    use context <- update_component(
        update_context(msg, model),
        update_rb,
        fn (model, msg) {
            case msg {
                Clicked -> model + 1
            }
        }
    )

    // handle second button's external events
    use context <- update_component(
        context,
        update_rb,
        fn (model, msg) {
            case msg {
                Clicked -> model - 1
            }
        }
    )

    // handle our own events
    use model, msg <- update_finally(context)
    case msg {
        Double -> model * 2
    }
}

pub fn main() {
    let app = lustre.simple(
        init,
        update,
        view,
    )
    let assert Ok(_) = lustre.start(app, "#app", Nil)
}
