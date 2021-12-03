import {
  Col,
  Row,
  Text,
  Box,
  Button,
  ManagedTextInputField,
  ManagedCheckboxField,
  ContinuousProgressBar,
} from "@tlon/indigo-react";
import { Formik, Form } from "formik";
import React, { useEffect } from "react";
import { useHistory, useLocation, useParams } from "react-router-dom";
import useGroupState from "~/logic/state/group";
import useInviteState, { useInviteForResource } from "~/logic/state/invite";
import useMetadataState, { usePreview } from "~/logic/state/metadata";
import { Invite } from "@urbit/api";
import { join, JoinRequest } from "@urbit/api/groups";
import airlock from "~/logic/api";
import { joinError, joinResult, joinLoad, JoinProgress } from "@urbit/api";
import { useQuery } from "~/logic/lib/useQuery";
import { JoinKind, JoinDesc, JoinSkeleton } from './Skeleton';

interface FormSchema {
  autojoin: boolean;
  shareContact: boolean;
}

const initialValues = {
  autojoin: false,
  shareContact: false,
};

function JoinForm(props: {
  desc: JoinDesc;
  dismiss: () => void;
  invite?: Invite;
}) {
  const { desc, dismiss, invite } = props;
  const onSubmit = (values: FormSchema) => {
    const [, , ship, name] = desc.group.split("/");
    airlock.poke(
      join(ship, name, desc.kind, values.autojoin, values.shareContact)
    );
  };
  const isGroups = desc.kind === "groups";

  return (
    <Formik initialValues={initialValues} onSubmit={onSubmit}>
      <Form>
        <Col p="4" gapY="4">
          {isGroups ? (<ManagedCheckboxField id="autojoin" label="Join all channels" />) : null}
          <ManagedCheckboxField id="shareContact" label="Share identity" />
          <Row gapX="2">
            <Button onClick={dismiss}>Dismiss</Button>
            <Button primary type="submit">
              {!invite ? "Join Group" : "Accept Invite"}
            </Button>
          </Row>
        </Col>
      </Form>
    </Formik>
  );
}
const REQUEST: JoinDesc = {
  group: "/ship/~bitbet-bolbel/urbit-community",
  kind: "groups",
};

export function JoinInitial(props: {
  invite?: Invite;
  desc: JoinDesc;
  modal: boolean;
  dismiss: () => void;
}) {
  const { desc, dismiss, modal, invite } = props;
  const title = (() => {
    const name = desc.kind === "graph" ? "Group Chat" : "Group";
    if (invite) {
      return `You've been invited to a ${name}`;
    } else {
      return `You're joining a ${name}`;
    }
  })();
  return (
    <JoinSkeleton modal={modal} desc={desc} title={title}>
      <JoinForm invite={invite} dismiss={dismiss} desc={desc} />
    </JoinSkeleton>
  );
}

function JoinLoading(props: {
  desc: JoinDesc;
  modal: boolean;
  request: JoinRequest;
  dismiss: () => void;
  finished: string;
}) {
  const { desc, request, dismiss, modal, finished } = props;
  const history = useHistory();
  useEffect(() => {
    if (request.progress === "done") {
      history.push(finished);
    }
  }, [request]);
  const name = desc.kind === "graph" ? "Group Chat" : "Group";
  const title = `Joining ${name}, please wait`;
  const onCancel = () => {
    useGroupState.getState().abortJoin(desc.group);
    dismiss();
  };
  return (
    <JoinSkeleton modal={modal} desc={desc} title={title}>
      <Col maxWidth="512px" p="4" gapY="4">
        {joinLoad.indexOf(request.progress as any) !== -1 ? (
          <JoinProgressIndicator progress={request.progress} />
        ) : null}
        <Box>
          <Text>
            If join seems to take a while, the host of the {name} may be
            offline, or the connection between you both may be unstable.
          </Text>
        </Box>
        <Row gapX="2">
          <Button onClick={dismiss}>Dismiss</Button>
          <Button destructive onClick={onCancel}>
            Cancel Join
          </Button>
        </Row>
      </Col>
    </JoinSkeleton>
  );
}

function JoinError(props: {
  desc: JoinDesc;
  request: JoinRequest;
  modal: boolean;
}) {
  const { desc, request, modal } = props;
  const { preview } = usePreview(desc.group);
  const group = preview?.metadata?.title ?? desc.group;
  const title = `Joining ${group} failed`;
  const explanation =
    request.progress === "no-perms"
      ? "You do not have the correct permissions"
      : "An unexpected error occurred";

  return (
    <JoinSkeleton modal={modal} title={title} desc={desc}>
      <Col p="4" gapY="4">
        <Text fontWeight="medium">{explanation}</Text>
        <Row>
          <Button>Dismiss</Button>
        </Row>
      </Col>
    </JoinSkeleton>
  );
}

export interface JoinProps {
  desc: JoinDesc;
  redir?: string;
  modal?: boolean;
  dismiss?: () => void;
}

export function Join(props: JoinProps) {
  const { desc, modal, dismiss, redir } = props;
  const { group, kind } = desc;
  const [, , ship, name] = group.split("/");
  const graph = kind === "graph";
  const finishedPath = !!redir
    ? redir
    : graph
    ? `/~landscape/messages/resource/chat/${ship}/${name}`
    : `/~landscape/ship/${ship}/${name}`;

  const history = useHistory();
  const joinRequest = useGroupState((s) => s.pendingJoin[group]);
  const invite = useInviteForResource(kind, ship, name);

  const isDone = joinRequest && joinRequest.progress === "done";
  const isErrored =
    joinRequest && joinError.includes(joinRequest.progress as any);
  const isLoading =
    joinRequest && joinLoad.includes(joinRequest.progress as any);

  useEffect(() => {
    if(isDone) {
      history.push(finishedPath);
    }
  }, [isDone, desc]);

  return isDone ? (
    <JoinDone modal={modal} desc={desc} />
  ) : isLoading ? (
    <JoinLoading
      modal={modal}
      dismiss={dismiss}
      desc={desc}
      request={joinRequest}
      finished={finishedPath}
    />
  ) : isErrored ? (
    <JoinError modal={modal} desc={desc} request={joinRequest} />
  ) : (
    <JoinInitial modal={modal} dismiss={dismiss} desc={desc} invite={invite} />
  );
}

interface PromptFormProps {
  kind: string;
}

interface PromptFormSchema {
  link: string;
}
export interface JoinPromptProps {
  kind: string;
  dismiss?: () => void;
}

export function JoinPrompt(props: JoinPromptProps) {
  const { kind, dismiss } = props;
  const { query, appendQuery } = useQuery();
  const history = useHistory();
  const initialValues = {
    link: "",
  };

  const onSubmit = async ({ link }: PromptFormSchema) => {
    const path = `/ship/${link}`;
    history.push({
      search: appendQuery({ "join-path": path }),
    });
  };

  return (
    <JoinSkeleton modal body={<Text>a</Text>} title="Join a Group">
      <Formik initialValues={initialValues} onSubmit={onSubmit}>
        <Form>
          <Col p="4" gapY="4">
            <ManagedTextInputField
              label="Invite Link"
              id="link"
              caption="Enter either a web+urbitgraph:// link or an identifier in the form ~sampel-palnet/group"
            />
            <Row gapX="2">
              {!!dismiss ? (
                <Button type="button" onClick={dismiss}>
                  Dismiss
                </Button>
              ) : null}
              <Button type="submit" primary>
                Join
              </Button>
            </Row>
          </Col>
        </Form>
      </Formik>
    </JoinSkeleton>
  );
}

function JoinProgressIndicator(props: { progress: JoinProgress }) {
  const { progress } = props;
  const percentage =
    progress === "done" ? 100 : (joinLoad.indexOf(progress as any) + 1) * 25;

  const description = (() => {
    switch (progress) {
      case "start":
        return "Connecting to host";
      case "added":
        return "Retrieving members";
      case "metadata":
        return "Retrieving channels";
      case "done":
        return "Finished";
      default:
        return "";
    }
  })();

  return (
    <Col gapY="2">
      <Text color="lightGray">{description}</Text>
      <ContinuousProgressBar percentage={percentage} />
    </Col>
  );
}

export interface JoinDoneProps {
  desc: JoinDesc;
  modal: boolean;
}

export function JoinDone(props: JoinDoneProps) {
  const { desc, modal } = props;
  const { preview, error } = usePreview(desc.group);
  const name = desc.kind === "groups" ? "Group" : "Group Chat";
  const title = `Joined ${name} successfully`;

  return (
    <JoinSkeleton title={title} modal={modal} desc={desc}>
      <Col p="4" gapY="4">
        <JoinProgressIndicator progress="done" />
        <Row gapX="2">
          <Button>Dismiss</Button>
          <Button primary>View Group</Button>
        </Row>
      </Col>
    </JoinSkeleton>
  );
}

export function JoinRoute(props: { graph?: boolean; modal?: boolean }) {
  const { modal = false, graph = false } = props;
  const { query } = useQuery();
  const history = useHistory();
  const { pathname } = useLocation();
  const kind = query.get("join-kind");
  const path = query.get("join-path");
  const redir = query.get('redir');
  if (!kind) {
    return null;
  }
  const desc: JoinDesc = path
    ? {
        group: path,
        kind: graph ? "graph" : "groups",
      }
    : undefined;

  const dismiss = () => {
    history.push(pathname);
  };

  return desc ? (
    <Join desc={desc} modal dismiss={dismiss} redir={redir} />
  ) : (
    <JoinPrompt kind={kind} dismiss={dismiss} />
  );
}
