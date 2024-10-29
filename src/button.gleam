import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import components.{
    type ComponentMessage,
    type ComponentState,
    internal,
    external,
}

pub type RainbowButtonInternalModel {
    Red
    Green
    Blue
}

pub type RainbowButtonExternalModel = String
pub type RainbowButtonInternalMessage { Hovered }
pub type RainbowButtonExternalMessage { Clicked }

pub fn init_rb(_flags: Nil) -> RainbowButtonInternalModel { Red }

pub fn update_rb(
    model: RainbowButtonInternalModel,
    message: RainbowButtonInternalMessage,
) -> RainbowButtonInternalModel {
    case message {
        Hovered -> case model {
            Red -> Green
            Green -> Blue
            Blue -> Red
        }
    }
}

pub fn view_rb(
    state: ComponentState(
        RainbowButtonInternalModel,
        RainbowButtonExternalModel,
    ),
) -> Element(ComponentMessage(
    RainbowButtonInternalMessage,
    RainbowButtonExternalMessage,
)) {
    let color = case state.internal {
        Red -> "red"
        Green -> "green"
        Blue -> "blue"
    }

    html.button(
        [
            event.on_click(external(Clicked)),
            event.on_mouse_enter(internal(Hovered)),
            attribute.style([#("border-color", color)])
        ],
        [
            html.text(state.external),
        ],
    )
}
