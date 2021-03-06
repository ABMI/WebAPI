package org.ohdsi.webapi.user.importer.service;

import org.ohdsi.analysis.Utils;
import org.ohdsi.webapi.Constants;
import org.ohdsi.webapi.user.importer.model.AtlasUserRoles;
import org.ohdsi.webapi.user.importer.model.LdapProviderType;
import org.ohdsi.webapi.user.importer.model.RoleGroupMapping;
import org.slf4j.LoggerFactory;
import org.springframework.batch.core.ExitStatus;
import org.springframework.batch.core.StepExecution;
import org.springframework.batch.core.StepExecutionListener;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.transaction.support.TransactionTemplate;

import java.util.List;

public class FindUsersToImportTasklet extends BaseUserImportTasklet<List<AtlasUserRoles>> implements StepExecutionListener {

  private List<AtlasUserRoles> userRoles;

  public FindUsersToImportTasklet(TransactionTemplate transactionTemplate,
                                  UserImportService userImportService) {

    super(LoggerFactory.getLogger(FindUsersToImportTasklet.class), transactionTemplate, userImportService);
  }

  @Override
  protected List<AtlasUserRoles> doUserImportTask(ChunkContext chunkContext, LdapProviderType providerType, Boolean preserveRoles, RoleGroupMapping roleGroupMapping) {

    userRoles = userImportService.findUsers(providerType, roleGroupMapping);
    return userRoles;
  }

  @Override
  public void beforeStep(StepExecution stepExecution) {
  }

  @Override
  public ExitStatus afterStep(StepExecution stepExecution) {

    stepExecution.getJobExecution().getExecutionContext().putString(Constants.Params.USER_ROLES, Utils.serialize(userRoles));
    return null;
  }
}
