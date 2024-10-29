import lustre/element.{type Element, map}

pub type ComponentState(a, b) {
    ComponentState(
        internal: a,
        external: b,
    )
}

pub opaque type ComponentMessage(a, b) {
    InternalMessage(a)
    ExternalMessage(b)
}

pub fn internal(a) -> ComponentMessage(a, b) {
    InternalMessage(a)
}

pub fn external(b) -> ComponentMessage(a, b) {
    ExternalMessage(b)
}

pub opaque type Product(a, b) { Product(a, b) }
pub opaque type Coproduct(a, b) { Left(a) Right(b) }

pub fn init_component(
    init: component,
    rest: fn() -> rest,
) -> Product(component, rest) {
    Product(init, rest())
}

pub opaque type UpdateContext(model, message, inner) {
    UpdateContinue(model: model, message: message)
    UpdateResolve(model: model, finish: fn(inner) -> inner)
}

pub fn update_context(
    model: model,
    message: message,
) -> UpdateContext(model, message, inner) {
    UpdateContinue(model, message)
}

pub fn update_component(
    context: UpdateContext(
        Product(model, model_rest),
        Coproduct(
            ComponentMessage(internal_message, external_message),
            message_rest,
        ),
        inner,
    ),
    handle_internal: fn(model, internal_message) -> model,
    handle_external: fn(inner, external_message) -> inner,
    rest: fn(
        UpdateContext(
            model_rest,
            message_rest,
            inner,
        ),
    ) -> model_rest,
) -> Product(model, model_rest) {
    case context {
        UpdateContinue(Product(model, remain), message) -> {
            case message {
                Left(InternalMessage(m)) -> {
                    Product(handle_internal(model, m), remain)
                }
                Left(ExternalMessage(m)) -> {
                    Product(model, rest(UpdateResolve(
                        model: remain,
                        finish: fn (inner) {
                            handle_external(inner, m)
                        },
                    )))
                }
                Right(m) -> {
                    Product(model, rest(UpdateContinue(
                        model: remain,
                        message: m,
                    )))
                }
            }
        }
        UpdateResolve(Product(model, remain), finish) -> {
            Product(model, rest(UpdateResolve(
                model: remain,
                finish: finish,
            )))
        }
    }
}

pub fn update_finally(
    context: UpdateContext(inner, message, inner),
    handle: fn(inner, message) -> inner,
) -> inner {
    case context {
        UpdateContinue(inner, message) -> {
            handle(inner, message)
        }
        UpdateResolve(inner, finish) -> {
            finish(inner)
        }
    }
}

pub type ViewContext(model, remaining_message, goal_message) {
    ViewContext(
        model: model,
        emit: fn(remaining_message) -> goal_message,
    )
}

pub fn view_context(
    model: model,
) -> ViewContext(model, goal_message, goal_message) {
    ViewContext(
        model: model,
        emit: fn (message) {
            message
        },
    )
}

pub fn view_component(
    context: ViewContext(
        Product(model, model_rest),
        Coproduct(message, message_rest),
        goal_message,
    ),
    draw_model: fn(ComponentState(model, params)) -> Element(message),
    rest: fn(
        fn(params) -> Element(goal_message),
        ViewContext(model_rest, message_rest, goal_message),
    ) -> Element(goal_message),
) {
    let Product(state, remaining) = context.model
    rest(
        fn (params) {
            map(
                draw_model(ComponentState(state, params)),
                fn (left) { context.emit(Left(left)) },
            )
        },
        ViewContext(
            remaining,
            fn (message) {
                context.emit(Right(message))
            },
        ),
    )
}
