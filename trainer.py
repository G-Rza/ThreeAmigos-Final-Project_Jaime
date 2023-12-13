
import turicreate as tc

training_data = tc.SFrame.read_json('training.json')
test_data = tc.SFrame.read_json('test.json')

model = tc.text_classifier.create(training_data, 'label', features=['text'], max_iterations=100)

predictions = model.predict(test_data)

metrics = model.evaluate(test_data)
print(metrics['accuracy'])

model.export_coreml('AppleTopicsTC.mlmodel')
