import Foundation
import UIKit
import Alamofire


final class NewScheduleViewModel: NSObject {

    final class Day {
        let title: String
        var lessons: [Lesson]

        init(weekDay: Int, lessons: [Lesson]) {
            self.lessons = lessons

            switch weekDay {
            case 1: title = "Понедельник"
            case 2: title = "Вторник"
            case 3: title = "Среда"
            case 4: title = "Четверг"
            case 5: title = "Пятница"
            case 6: title = "Суббота"
            default: title = ""
            }
        }
    }

    // MARK: - Public Properties

    var dataUpdateDidFinishSuccessfully: (() -> Void)?
    var dataUpdateDidFinishWithError: ((Error) -> Void)?

    // MARK: - Private Properties

    private var schedule = [Day]()

    // MARK: - Public Methods

    func update(for group: Int, on weekOffset: Int) {
        ApiManager.shared.getStudentSchedule(for: group, on: weekOffset) { response in
            switch response.result {
            case .success(let result):
                DispatchQueue.main.async {
                    self.requestSucceeded(with: result)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.requestFailed(with: error, and: response)
                }
            }
        }
    }

    // MARK: - Private Methods

    private func requestSucceeded(with response: [Lesson]) {
        schedule = (1...6).map { weekDay in
            Day(weekDay: weekDay!, lessons: response.filter {
                $0.weekDay == weekDay ? true : false
            }.sorted())
        }
        guard let callback = dataUpdateDidFinishSuccessfully else { return }
        callback()
    }

    private func requestFailed(with error: Error, and response: DataResponse<[Lesson], AFError>) {
        guard let callback = dataUpdateDidFinishWithError else { return }
        callback(error)
    }
}

extension NewScheduleViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }


}

extension NewScheduleViewModel: UITableViewDelegate {

}
