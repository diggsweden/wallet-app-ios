// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public struct ProblemParameter: Sendable {
  public let property: String?
  public let reason: String?
  public let value: String?
}

public struct ProblemDetails: Sendable {
  public let status: Int
  public let type: String?
  public let title: String?
  public let detail: String?
  public let instance: String?
  public let transactionId: String?
  public let invalidParameters: [ProblemParameter]?
}

extension ProblemDetails {
  init(status: Int, response: Components.Responses.Default) {
    let problem = try? response.body.applicationProblemJson
    self.init(
      status: status,
      type: problem?._type,
      title: problem?.title,
      detail: problem?.detail,
      instance: problem?.instance,
      transactionId: problem?.transactionId,
      invalidParameters: problem?.invalidParameters?.map(ProblemParameter.init)
    )
  }
}

extension ProblemParameter {
  init(_ dto: Components.Schemas.ProblemParameterResponse) {
    self.init(property: dto.property, reason: dto.reason, value: dto.value)
  }
}
