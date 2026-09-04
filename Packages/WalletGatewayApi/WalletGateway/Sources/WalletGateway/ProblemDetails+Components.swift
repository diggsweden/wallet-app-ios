// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import WalletGatewayInterface

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
      invalidParameters: problem?.invalidParameters?.map(ProblemParameter.init),
    )
  }

  init(from problem: Components.Schemas.ProblemResponse) {
    self.init(
      status: problem.status,
      type: problem._type,
      title: problem.title,
      detail: problem.detail,
      instance: problem.instance,
      transactionId: problem.transactionId,
      invalidParameters: problem.invalidParameters?.map(ProblemParameter.init),
    )
  }
}

extension ProblemParameter {
  init(_ dto: Components.Schemas.ProblemParameterResponse) {
    self.init(property: dto.property, reason: dto.reason, value: dto.value)
  }
}
