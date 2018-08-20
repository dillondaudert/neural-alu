# Helper functions for training Flux models
using Flux: train!, @epochs, params, SGD, mse

function train_and_eval!(model, tr_data, val_data, n_epochs)
    loss(x, y) = mse(model(x), y)
    opt = SGD(params(model), η=0.001)
    @epochs n_epochs train!(loss, tr_data, opt)
    
end